+++
title = "[Go번역] Go에서의 일반적인 Anti-patterns"
date = 2021-05-04T17:53:35+09:00
tags = ["go", "translate"]
categories = ["devnote"]
draft = false
+++
> 이 글은 [Common anti-pattern in Go](https://dev.to/deepsource/common-anti-patterns-in-go-fm7) 포스트를 번역한 글로 오역 및 의역이 포함될 수 있습니다.

코딩이 예술이라는 것은 널리 알려져 있고, 좋은 작품을 만들어내고 그것을 자랑스러워하는 모든 예술가처럼, 우리 개발자들도 예술가로서 우리가 작성한 코드에 자랑스러워한다. 예술가들은 최고의 결과를 얻기 위해 그들의 능력을 향상시킬 방법과 도구를 끊임 없이 찾는다. 비슷하게 우리도 개발자로서 우리의 스킬을 높이고 가장 중요한 질문인 **"좋은 코드를 작성하는 방법"**에 대한 답을 알고 싶어 한다.

Federic P.Brooks는 자신의 책 **"The Mythical Man Month: Essay on Software Engineering"** 에서 이렇게 말한다.

> _"프로그래머는 시인과 비슷하게 수수한 생각에서 약간 벗어나서 일을 한다. 그들은 공기안에서, 공기로부터 상상력을 발휘하여 자신의 성을 짓는다. 유연하고 다듬고 재작업하기 쉬우며 거대한 개념구조를 쉽게 실현할 수 있는 창조 매체는 거의 없다._

이 포스트는 위 그림의 큰 물음표에 대한 답을 찾으려 노력한다. 좋은 코드를 작성하는 가장 간단한 방법은 우리의 코드에 **바람직하지 않은 패턴**을 포함시키지 않는 것이다.

![how to write good code comic](/images/how-to-write-good-code-comic.png)

## 바람직하지 않은 패턴(anti-patterns)이란 무엇인가?

Anti-patterns은 향후 고려대상을 생각하지 않고 코드를 작성할때 발생한다. Anti-patterns은 처음에는 문제에 대한 적절한 해결방법이라고 보일수 있지만, 실제로는 코드베이스가 확장됨에 따라 모호해지고 우리의 코드베이스에 '기술적 부채(technical debt)'를 더하게 된다.

Anti-pattern의 간단한 예로는 아래 예제 1번처럼, API 사용자가 어떻게 사용하는지를 고려하지 않고 API를 개발한 것이다. Anti-pattern이 무엇인지 알고 프로그래밍을 하면서 의식적으로 사용을 피하는 것은 더욱 가독성/유지보수성이 좋은 코드베이스로 가는데에 중요한 과정이다. 이 포스트에서 Go에서 일반적으로 범하는 Anti-patterns들에 대해 살펴본다.

## 1. 외부 호출 함수에서 unexported type을 리턴하는 것

Go에서 우리는 어떤 `field`나 `variable`를 `export`하기 위해선 그것의 이름의 첫 시작을 대문자로 해주어야 한다. 그것들을 exporting하는 동기는 다른 패키지에서 그것들을 보이게 하기 위해서이다. 예를들어 `math`패키지의 `Pi`함수를 사용하고자 한다면, 우리는 `math.Pi`라는 형태로 호출해야한다. `math.pi`를 사용한다면 동작하지 않고 에러를 낼 것이다.

소문자로 시작하는 이름(구조체 필드, 함수, 변수)은 unexported 하며, 오직 그것을 정의한 패키지 내부에서만 보인다.

외부 호출 함수나 메소드에서 unexported type를 리턴하는 것은 해당 함수를 호출한 사용자가 그것을 사용하기 위해서 다시 타입을 정의해야 하므로 사용하는데 불편할 수 있다.

```go
// Bad practice
type unexportedType string
func ExportedFunc() unexportedType {
    return unexportedType("some string")
}

// Recommended
type ExportedType string
func ExportedFunc() ExportedType {
    return ExportedType("some string")
}
```

## 2. 불필요한 blank identifier(_)의 사용

많은 상황에서 값을 blank identifier에 할당하는것은 불필요하다. `for`루프에서 blank identifier를 사용하는 경우에 대해 Go Specdms 다음과 같이 언급한다.

> 마지막 반복 변수가 blank identifier인 경우는 해당 blank identifier가 없는 경우와 동일하다.

```go
// Bad practice
for _ = range sequence {
    run()
}
x, _ := someMap[key]
_ = <-ch

// Recommended
for range something {
    run()
}
x := someMap[key]
<-ch
```

## 3. 두 슬라이스를 연결하기 위한 loop/multiple `append` 사용

두 슬라이스를 하나로 합치려 할 때, 슬라이스를 순회하며 각 요소를 하나씩 추가할 필요가 없다. 대신 하나의 `append`구문으로 사용하는 것이 훨씬 효율적이고 좋다.

예를 들어, 아래 예제 코드는 `sliceTwo`를 순회하며 각 요소를 하나씩 추가하여 합치고 있다.

```go
for _, v := range sliceTwo {
    sliceOne = append(sliceOne, v)
}
```

하지만 `append`는 `variadic`한 함수이기 때문에 0개 또는 다수의 인자로 호출될 수 있다. 따라서, 위의 예제는 아래처럼 하나의 `append`함수를 사용하여 훨신 간단하게 개선할 수 있다.

```go
sliceOne = append(sliceOne, sliceTwo…)
```

## 4. `make`호출 내 불필요한 인자

`make`함수는 맵, 슬라이스, 채널 타입의 객체를 초기화하고 할당하는데 사용되는 특별한 내장 함수이다. `make`를 통해 슬라이스를 초기화하기 위해서 우리는 슬라이스 타입, 슬라이스의 길이, 슬라이스의 용량을 인자로 전달 해야한다. `make`를 통해 맵을 초기화하는 경우에는 `map`의 사이즈를 인자로 전달해야 한다.

하지만 `make`는 아래 인자들에 대한 기본값을 갖는다.

- 채널일 경우, 버퍼의 용량을 0으로 함(unbuffered)
- 맵일 경우, 사이즈는 작은 시작 사이즈를 기본값으로 할당됨
- 슬라이스일 경우, 용량이 생략되면 길이와 같게 용량이 설정됨

따라서,

```go
ch = make(chan int, 0)
sl = make([]int, 1, 1)
```

위의 코드는 아래처럼 개선될 수 있다.

```go
ch = make(chan int)
sl = make([]int, 1)
```

하지만, 채널에 명명된 상수를 사용하는 것은 디버깅을 위한 목적으로 하거나, 수학, 플랫폼 별 코드를 수용하기 위해 anti-pattern으로 간주되지 않는다.

```go
const c = 0
ch = make(chan int, c) // Not an anti-pattern
```

## 5. 함수 내 쓸모없는 `return`

리턴값을 갖지 않는 함수에서 `return`구문을 마지막에 넣는 것은 좋은 방법이 아니다.

```go
// Useless return, not recommended
func alwaysPrintFoofoo() {
    fmt.Println("foofoo")
    return
}

// Recommended
func alwaysPrintFoo() {
    fmt.Println("foofoo")
}
```

하지만 명명된 리턴을 쓸모없는 리턴과 혼동하면 안된다. 아래 리턴 구문은 실제로 리턴값을 갖는다.

```go
func printAndReturnFoofoo() (foofoo string) {
    foofoo := "foofoo"
    fmt.Println(foofoo)
    return
}
```

## 6. `switch`구문 내 쓸모 없는 `break`

Go에선 `switch`구문은 자동적인 `fallthrough`을 갖지 않는다. C같은 프로그래밍 언어에선 `break`구문이 없다면 다음 케이스에대한 연산이 통과된다. 하지만 `switch`-case 구문의 `fallthrough`는 매우 드물게 사용되고 대부분 버그를 유발한다는 것이 일반적이다. 따라서 Go를 포함한 현대의 프로그래밍 언어에서는 해당 로직을 `fallthrough`되지 않는 것을 기본으로 변경했다.

따라서 `switch`구문에서 케이서의 마지막에 `break`구문을 넣는것은 필요하지 않다. 아래 두 예제는 동일하게 동작한다.

나쁜 예제:

```go
switch s {
case 1:
    fmt.Println("case one")
    break
case 2:
    fmt.Println("case two")
}
```

좋은 예제:

```go
switch s {
case 1:
    fmt.Println("case one")
case 2:
    fmt.Println("case two")
}
```

하지만 만약 Go에서 `switch`내에 `fallthrough`를 구현해야하는 상황이라면, 우리는 아래 예제처럼 `fallthrough`구문을 사용할 수 있다.

```go
switch s {
case 1:
    fmt.Print("1")
    fallthrough
case 2:
    fmt.Print("2")
    fallthrough
case 3: fmt.Print("3")
}
```

## 7. 일반적인 작업에 helper 함수를 사용하지 않는 것

특정 인자의 집합에 대해 어떤 함수는 효율성 향상과 이해/가독성 향상을 위해 대신 사용할 수 있는 함수가 있다.

예를 들어 Go에선, 다수의 고루틴의 종료를 기다리기 위해 `sync.WaitGroup`을 사용할 수 있는데, `sync.WaitGroup`을 증가시키는 것을 대신 아래처럼 카운터를 `1`증가시키고 모든 고루틴이 수행되었다는걸 알기 위해 `-1`을 추가해 카운터를 0으로 만든다.

```go
wg.Add(1)
// ...some code
wg.Add(-1)
```

하지만 `sync.Waitgroup`에는 수동으로 카운터를 `0`으로 만들 필요 없이 모든 고루틴의 완료를 알 수 있는 `wg.Done()`이라는 훨씬 이해하기 쉬운 helper 함수가 있다.

```go
wg.Add(1)
// ...some code
wg.Done()
```

## 8. 불필요한 슬라이스 nil 체크

`nil`슬라이스의 길이는 0으로 계산된다. 따라서 길이를 확인하기 전에 해당 슬라이스가 `nil`인지 아닌지 확인할 필요가 없다.

아례 예제에서 `nil`체크는 불필요한 부분이다.

```go
if x != nil && len(x) != 0 {
    // do something
}
```

위의 예제는 `nil`체크를 생략하여 수정될 수 있다.

```go
if len(x) != 0 {
    // do something
}
```

## 9. 너무 복잡한 함수 리터럴

단일 함수만 호출하는 함수 리터럴은 중복되므로 내부 함수의 값에 다른 변경 없이 제거될 수 있다. 대신, 외부 함수 내부에서 호출되는 내부 함수는 호출 되어야 한다.

```go
// not recommanded
fn := func(x int, y int) int { return add(x, y) }

// Recommanded
fn := add
```

## 10. 단일 케이스에서의 `select`구문 사용

`select`구문을 통해 다수의 통신 작업에서 고루틴의 대기를 할 수 있다. 하지만 하나의 작업/케이스라면, 우리는 실제로 `select`구문이 필요하지 않다. 단순한 `send`또는 `receive`작업이 도움이 될 수 있다. 만약 블로킹 없이 send/receive를 해야하는 상황이라면, `select`를 non-blocking으로 만들기 위해 `default`구문을 추가하는 것이 좋다.

```go
// Bad pattern
select {
case x := <-ch:
    fmt.Println(x)
}

// Recommended
x := <-ch
fmt.Println(x)
```

`default` 사용:

```go
select {
case x := <-ch:
    fmt.Println(x)
default:
    fmt.Println("default")
}
```

## 11. context.Context는 함수의 첫번째 파라미터여야 한다

context.Context는 관용적으로 ctx라는 이름으로 첫번째 파리미터여야 한다. ctx는 Go 코드에서 많은 함수에 사용되는 공통 인자이고, 논리적으로 인수 집합에 가장 첫번째 혹은 마지막에 놓는 것이 좋기 때문이다. 왜 그럴까? 이것은 우리가 ctx의 사용의 균일한 패턴 때문에 구문을 포함시키는 것을 기억하도록 도와준다. Go에서 `variadic`한 변수는 인수 집앞에 마지막에 올 것이기 때문에 context.Context는 첫번째 인자로 두는 것이 좋다. Node.js와 같은 다양한 프로젝트에도 첫번째 error callback과 같은 컨벤션이 있다. 마찬가지로 context.Context는 항상 함수의 첫번째 파라미터여야 한다는 컨벤션이 있다.

```go
// Bad practice
func badPatternFunc(k favContextKey, ctx context.Context) {
    // do something
}

// Recommended
func goodPatternFunc(ctx context.Context, k favContextKey) {
    // do something
}
```

_원문에는 자동화 코드 리뷰 툴인 DeepSource에 대한 내용이 기술되어 있지만 본 포스트의 내용과는 무관하다 판단되어 생략하였습니다._
