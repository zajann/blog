+++
title = "[Go] Benchmark Test 사용하기"
date = 2021-05-03T11:09:02+09:00
tags = ["go", "test"]
categories = ["devnote"]
draft = false
+++

## Intro

Go로 개발을 하다보면 빈번하게 사용되는 패키지가 `time`패키지다. 그런데 timestamp와 같은 시간 정보를 가져올 때마다 매번 `time.Now()`를 호출하는 것이 조금 비효율적으로 보였다. 그래서 주기적으로 업데이트되는 내부 `time.Time`인스턴스를 갖고 값만 전달하는 패키지를 만들었다. 

시스템콜로 계속해서 시간 정보를 가져오는 것보다 독립적으로 업데이트되는 값을 가져오는게 더 효율적이라고 생각했다. Default 주기를 100ms으로 설정해놓았는데 ms단위 이하의 정교한 시간 정보를 가지고 오는  경우가 아니라면 발생할 수 있는 시간차는 괜찮을 것 같다. 

해당 패키지의 소스는 [여기](https://github.com/zajann/timer) 에서 볼 수 있다.

자 그러면 이제 실제로 효과가 있는지를 확인 해봐야하는데, 이때 `go test` 를 통해서 손쉽게 benchmark 테스트를 할 수 있다. 사용하는 김에 Go Benchmark Test의 방법에 대해 정리해 본다.

## Basic Usage

`go test` 를 유닛테스트에 사용하기 위해 지켜줘야 하는 몇가지 규칙이 있는데, benchmark 테스트도 이와 유사하다.

```go
package main

import (
    "testing"
    "time"
)

func BenchmarkTimeNow(b *testing.B) {
    for i:= 0; i < b.N; i++ {
        time.Now()
    }
}
```

- 테스트 파일의 이름은 *_test.go로 만든다.
- 테스트 함수는 `Benchmark`로 시작하는 이름을 갖는다.
- 테스트 함수는 *testing.B 타입의 매개 변수를 받는다.

테스트는 코드에서 알 수 있듯이 `b.N`에 정의된 값만큼 반복하여 성능을 측정할 함수를 호출한다.

아래의 명령으로 benchmark 테스트를 실행할 수 있다.

```bash
$ go test -bench=.
```

일반적인 유닛테스트와 비슷하지만 `-bench` flags를 통해 benchmark 테스트를 실행한다. 

```
goos: linux
goarch: amd64
pkg: github.com/zajann/timer
BenchmarkTimeNow-16     19308310                62.3 ns/op
PASS
ok      github.com/zajann/timer 1.989s
```

결과를 보면 총 19308310번 반복했고 수행시간으로 평균 62.3 ns이 걸렸다는 걸 알 수 있다.

위의 `-bench=.`의 `.`의 의미는 모든 테스트 함수를 의미하는데, 만약 현재 디렉토리에 다른 테스트 함수들이 존재하고 특정 함수만을 테스트하고 싶다면 해당 함수의 이름을 명시하면된다. 

```bash
$ go test -bench=BenchmarkTimeNow
```

`-bench` flag의 인자값을 정규표현식으로 하여 보다 다양한 케이스를 명시할 수있다. (~~함수명을 잘지어놔야겠다~~)

```
        -bench regexp
            Run only those benchmarks matching a regular expression.
            By default, no benchmarks are run.
            To run all benchmarks, use '-bench .' or '-bench=.'.
            The regular expression is split by unbracketed slash (/)
            characters into a sequence of regular expressions, and each
            part of a benchmark's identifier must match the corresponding
            element in the sequence, if any. Possible parents of matches
            are run with b.N=1 to identify sub-benchmarks. For example,
            given -bench=X/Y, top-level benchmarks matching X are run
            with b.N=1 to find any sub-benchmarks matching Y, which are
            then run in full.
```

## -benchmem

성능 측정 시 `-benchmem` flag를 통해 메모리 관련 정보도 얻을 수 있다.

```bash
$ go test -bench=. -benchmem
```

```
goos: linux
goarch: amd64
pkg: github.com/zajann/timer
BenchmarkTimeNow-16     18779935                60.2 ns/op             0 B/op          0 allocs/op
PASS
ok      github.com/zajann/timer 1.927s
```

평균 수행 시간과 함께 수행 당 사용된 메모리와 일어난 메모리 할당 횟수의 정보를 알 수 있다. 

## -benchtime

benchmark 테스트는 기본값으로 1초 동안 수행되도록 되어있다. 만약 수행 시간을 설정하고 싶다면 `-benchtime`flag를 통해 할 수 있다.

```bash
$ go test -bench=. -benchmem -benchtime=10s
```

10초 동안 테스트를 수행하겠다는 의미이다. 초단위 뿐만이 아니라 분, 시간단위로도 지정이 가능하다.

그럼 반복 횟수를 지정할순 없을까? 

[Go 1.12](https://golang.org/doc/go1.12) 버전부터, `-benchtime` 에 반복 횟수를 지정할 수 있도록 지원한다. 

```bash
$ go test -bench=. -benchmem -benchtime=10000x
```

`x` suffix를 통해 지정이 가능하다.

보다 다양한 go test 관련 flag의 설명은 아래 명령으로 살펴볼 수 있다.

```bash
$ go help testflag
```

## Outro

자 그럼 위에 설명한 `timer`패키지는 실제로 효과가 있었을까?

```go
package timer

import (
        "testing"
        "time"
)

func BenchmarkGetFormatStringWithTimer(b *testing.B) {
    Init(0)

    for i := 0; i < b.N; i++ {
            GetTimeFormat("2006-01-02 15:04:05")
    }
}

func BenchmarkGetFormatStringWithoutTimer(b *testing.B) {
    for i := 0; i < b.N; i++ {
            time.Now().Format("2006-01-02 15:04:05")
    }
}

func BenchmarkGetMonthStringWithTimer(b *testing.B) {
    Init(0)

    for i := 0; i < b.N; i++ {
            GetMonthString()
    }
}

func BenchmarkGetMonthStringWithoutTimer(b *testing.B) {
    for i := 0; i < b.N; i++ {
            time.Now().Month().String()
    }
}
```

패키지에 포함된 테스트 코드이다.

```bash
$ go test -bench=BenchmarkGetFormatString* -benchmem -benchtime=1000000x
```

```
goos: linux
goarch: amd64
pkg: github.com/zajann/timer
BenchmarkGetFormatStringWithTimer-16             1000000               476 ns/op              32 B/op          1 allocs/op
BenchmarkGetFormatStringWithoutTimer-16          1000000               543 ns/op              32 B/op          1 allocs/op
PASS

```

근소한 차이이지만 `timer`를 사용하는게 조금 빠르다. layout을 토대로 string을 만드는것은 동일하니 여기서 차이가 발생하진 않겠지만 `time.Time` 을 매번 생성하는 부분에서 차이가 있을 것 같다.

```bash
$ go test -bench=BenchmarkGetFormatString* -benchmem -benchtime=10000000x
```

```
pkg: github.com/zajann/timer
BenchmarkGetMonthStringWithTimer-16             10000000                 4.20 ns/op            0 B/op          0 allocs/op
BenchmarkGetMonthStringWithoutTimer-16          10000000                95.2 ns/op             0 B/op          0 allocs/op
PASS
ok      github.com/zajann/timer 1.000s

```

현재 월을 가져오는 부분에서는 큰 차이가 나타났다. 기존에는 매번 `time.Time`를 생성해 string을 반환하는 반면, `timer`의 경우 내부 인스턴스의 값을 그대로 반환하기 때문에 훨씬 빠르게 수행된다.

참 재밌다.
