+++
title = "[Go번역] sync.Pool 디자인 이해하기"
date = 2021-04-14T23:37:13+09:00
tags = ["go", "translate"]
categories = ["devnote"]
draft = false

+++

> 이 포스트는 [Go: Understand the Design of Sync.Pool](https://medium.com/a-journey-with-go/go-understand-the-design-of-sync-pool-2dde3024e277) 블로그 포스트를 번역한 것으로 오역 또는 의역이 포함될 수 있습니다.

이 글은 Go.1.12과 1.13 버전에 기반하고 두 버전 사이의 `sync/pool.go` 의 변화를 설명한다.

`sync`패키지는 강력한 인스턴스 풀을 제공하고 재사용을 통해 가비지 컬랙터로부터의 부담을 덜 수 있다. 패키지를 사용해보기 전에, 어플리케이션를 벤치마킹 테스트 해보는 것이 매우 중요한데, 내부적으로 동작하는 방식을 잘 이해하지 못한다면 오히려 성능이 저하될 수 있기 때문이다.

## Pool 제한

간단한 예제를 통해 1k 메모리 할당의 상황에서 어떻게 동작하는지 살펴보자

``` go
type Small struct {
   a int
}

var pool = sync.Pool{
   New: func() interface{} { return new(Small) },
}

//go:noinline
func inc(s *Small) { s.a++ }

func BenchmarkWithoutPool(b *testing.B) {
   var s *Small
   for i := 0; i < b.N; i++ {
      for j := 0; j < 10000; j++ {
         s = &Small{ a: 1, }
         b.StopTimer(); inc(s); b.StartTimer()
      }
   }
}

func BenchmarkWithPool(b *testing.B) {
   var s *Small
   for i := 0; i < b.N; i++ {
      for j := 0; j < 10000; j++ {
         s = pool.Get().(*Small)
         s.a = 1
         b.StopTimer(); inc(s); b.StartTimer()
         pool.Put(s)
      }
   }
}
```

`sync.Pool`을 사용하지 않은 것과 사용한 두 가지 벤치마크 테스트가 있고 가져오는 이점은 아래와 같다.

```
name           time/op        alloc/op        allocs/op
WithoutPool-8  3.02ms ± 1%    160kB ± 0%      1.05kB ± 1%
WithPool-8     1.36ms ± 6%   1.05kB ± 0%        3.00 ± 0%
```

루프는 10k의 반복을 갖기 때문에, 풀을 사용하지 않은 벤치마크 테스트는 10k번의 메모리 할당(allocation)이 일어났고, 반면에 풀을 사용한 경우에는 단지 3번만 일어났다. 저 3번의 메모리 할당은 풀에서 만들어진 것인데 실제는 오직 하나의 인스턴스만이 할당되었다. 지금까지만 보면, `sync.Pool`을 사용하는 것은 훨씬 빠르고 훨씬 적은 메모리를 사용한다.

하지만, 현실 상황에서는 풀을 사용하더라도 heap영역에 대한 새로운 메모리 할당이 많이 일어날 것이다. 이런 경우에 메모리는 증가할 것이고, 그것은 가비지 컬렉션을 일으킬 것이다. 우리는 `runtime.GC()`를 통해 가비지 컬렉터를 강제로 구동시켜 이런 상황을 재현해볼 수 있다.

```
name           time/op        alloc/op        allocs/op
WithoutPool-8  993ms ± 1%    249kB ± 2%      10.9k ± 0%
WithPool-8     1.03s ± 4%    10.6MB ± 0%     31.0k ± 0%
```

이제 풀을 사용한 경우에 오히려 성능이 떨어지고 메모리 할당 수와 사용량이 높아진 걸 확인할 수 있다. 왜 이런일이 일어나는지 패키지를 조금 더 깊게 살펴보자.

## 내부 구동 원리

`sync/pool.go`를 살펴보다보면 패키지의 초기화 선언을 볼 수 있는데 이것이 답을 줄 수 있다.

```go
func init() {
   runtime_registerPoolCleanup(poolCleanup)
}
```

풀을 정리하는 방식을 런타임에 등록한다. 그리고 이 방식은 가비지 컬렉터에 의해서도 똑같이 실행되는데 해당 코드 부분을 보면 아래와 같다.

```go
func gcStart(trigger gcTrigger) {
   [...]
   // clearpools before we start the GC
   clearpools()
```

이것을 통해 왜 가비지 컬렉터가 호출될 때 성능이 저하되는지 설명할 수 있다. 풀은 가비지 컬렉터가 구동될때마다 지워진다(clear). [공식 문서](https://golang.org/pkg/sync/#Pool)에서도 아래와 같이 경고한다.

> 풀에 저장된 항목은 언제든 알림 없이 자동적으로 제거될 수 있다.

이제 항목들이 어떻게 관리되는지 이해하기 위해 동작원리를 살펴보자.

![](/images/go-pool-workflow.png)

각 생성한 `sync.Pool`마다, go는 각 프로세서에 연결된 내부 풀인 `poolLocal`를 생성한다. 이 내부 풀은 `private`과 `shared`의 두가지 속성으로 구성된다. 첫 번째는 오직 소유자만이 접근 가능하다는 것이다. (push와 pop, 따라서 lock이 필요하지 않음) 반면에 `shared`속성은 다른 프로세서에서 읽을 수 있고 동시성 제어의 부분(concurrency-safe)이 필요하다. 실제로 이 풀은 단순한 로컬 캐시가 아니고, 어플리케이션이 모든 쓰레드이나 고루틴에서 사용이 가능하다.

Go 1.13 버전에서 공유 항목(shared item)에 대한 접근을 개선했고 가비지 컬렉터와 풀이 초기화되는 것과 관련있던 이슈를 해결할 새로운 캐시를 선보였다.

## 새로운 lock-free 풀과 희생 캐시(victim cache)

Go 1.13 버전에서 [새로운 이중 연결 리스트](https://github.com/golang/go/commit/d5fd2dd6a17a816b7dfd99d4df70a85f1bf0de31#diff-491b0013c82345bf6cfa937bd78b690d)를 공유 풀로 lock을 제거하고 공유 접근을 개선했다. 이것은 캐시를 개선하기 위한 기초이다. 공유 접근에 대한 새로운 동작 원리를 살펴보자.

![](/images/go-new-shared-pools-workflow.png)

이 새로운 체이닝 풀에서는, 각 프로세서는 이 큐의 head에서 데이터를 넣고 빼는 반면, 공유 접근 시에는 tail에서 값을 빼게 된다. 큐의 head는 `next / prev`의 속성 덕분에 이전 것과 연결되는 새로운 구조를 두 배 크게 할당하여 확장할 수 있다. 최초 구조의 기본 사이즈는 8 개이며 두 번째에는 16, 세 번째에는 32, 이런 식으로 계속 확장되어 포함할 수 있음을 의미한다. 또한 이제 lock이 필요하지 않으며 코드는 `atomic operation`에 의존할 수 있다.

새로운 캐시와 관련해 전략은 꽤 간단하다. 활성 풀과 아카이브 풀 두 가지 종류의 풀이 있다. 가비지 컬렉터가 실행 될 때, 각 풀의 참조를 풀 내부의 새로운 속성으로 유지한 다음, 현재 풀들이(pools) 초기화 되기 전에 풀을 아카이브 풀로 복사한다. 

```go
// Drop victim caches from all pools.
for _, p := range oldPools {
   p.victim = nil
   p.victimSize = 0
}

// Move primary cache to victim cache.
for _, p := range allPools {
   p.victim = p.local
   p.victimSize = p.localSize
   p.local = nil
   p.localSize = 0
}

// The pools with non-empty primary caches now have non-empty
// victim caches and no pools have primary caches.
oldPools, allPools = allPools, nil
```

이 전략을 통해 앱은 백업과 함께 새로운 항목을 생성/수집하는 가비지 컬렉터의 주기를 한번 더 갖게 된다. 이 동작 원리에서, 희생 캐시(victim cache)는 공유 풀 다음에 프로세스의 마지막에 호출 된다.