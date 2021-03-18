+++
title = "[Python] 파이썬 기초를 알아보자"
date = 2021-03-18T20:34:46+09:00
tags = ["python"]
categories = ["devnote"]
draft = false

+++

> 수박 겉핥기로만 알아오던 파이썬의 문법과 구문에 대해 정리해본다. 
>
> 인터넷, 서적에 있는 많은 내용을 참고하고 정리한다.
>
> _Last Update: 2021-03-18_

---

## 리스트 컴프리헨션(List Comprehension)

기존 리스트를 기반으로 새로운 리스트를 만들어내는 구문으로 파이썬의 대표적인 특징이다. 많이 사용해보고 익혀야 한다.

```python
# 홀수인 경우 2를 곱해 출력하는 리스트 컴프리헨션
[n * 2 for n in range(1, 11) if n % 2 == 1]	# [2, 6, 10, 14, 18]
```

버전 2,7 이후에는 리스트 외에도 딕셔너리 등이 가능하도록 추가됐다.

```python
# Code 1
a = {}
for key, value in somthing.items():
  	a[key] = value
    
# Code 2 (with comprehension)
a = {key: value for key, value in somethin.items()}
```

리스트 컴프리헨션은 파이썬의 매우 강력한 기능 중 하나이지만, 특유의 문법과 의미를 축약하여 나태는 특징 탓에 지나치게 남발하면 파이썬의 가독성을 떨어트리는 요인이 되기도 한다. 따라서 표현식이 2개를 넘지 않도록하고 역할별로 줄 구분을 통해 가독성을 높히도록 해야한다. 경우에 따라 가독성을 위해 모두 풀어쓰는 것도 검토해야 한다. 너무 짧은 라인 수를 고집할 필요는 없다. 

---

## 제너레이터(Generator)

_Keyword: `yield` `next()`_

루프의 반복(Iteration)동작을 제어할 수 있는 루틴 형태를 의미한다. 만약 `숫자 1억 개를 만들어내 계산하는 프로그램`을 작성한다면? 제너레이터가 없다면 메모리 어딘가에 생성한 숫자 1억 개를 보관하고 있어야 한다. 하지만 제너레이터만 생성해두고 필요할 때 언제든 숫자를 만들어낼 수 있다. 

`yield`구문을 통해 제너레이터를 리턴한다. 

```python
def get_increase_num():
		n = 0
    while True:
      	n += 1
        yield n		# yield를 통해 해당 함수는 제너레이터가 됨
```

제너레이터의 다음 값을 생성하려면 `next()`로 추출하면 된다. 

```python
g = get_increase_num()
for _ in range(0, 100):		# 제너레이터(g)를 통해 100번 값을 생성
  	print(next(g))
```

---

## range

제너레이터의 방식을 활용하는 대표적인 함수. 주로 for문에서 쓰인다. 

버전 3이후, `range()`함수가 제너레이터 역할을 하는 `range` 클래스를 리턴하는 형태로 변경되었다. 

제너레이터의 사용은 메모리 효율에 장점이 있는데, 만약 숫자 100만개를 생성하는 아래 두 가지 방법을 비교하면 이를 확인할 수 있다.

```python
a = [n for n in range(1000000)]
b = range(1000000)
```

`a`와 `b` 모두 100만개의 숫자를 가지고 있는 리스트처럼 보인다. (길이와 비교 연산도 동일) 하지만 여기서 `b`는 제너레이터인 `range` 클래스이다. 둘의 차이는 `a`는 이미 생성된 값이 담겨 있고 `b`는 생성해야 한다는 조건만 존재한다는 것이다. 따라서 둘 사이에는 메모리 점유율에 극명한 차이가 있다. 이처럼 큰 값을 생성해야 하는 경우 제너레이터를 활용하면 메모리 효율을 높일 수 있다.

여기서 더 놀라운 것은 인덱스로 접근이 가능하다는 것이다. 인덱스 접근 시 바로 생성하도록 구현되어 있기 때문에 리스트와 거의 동일한 느낌으로 사용이 가능하다.

```python
b[999]	# 999
```

---

## enumerate

순서가 있는 자료형(list, set, tuple 등)을 인덱스를 포함한 `enumerate`객체로 리턴한다.

```python
a = [1,2,3]
list(enumerate(a))		# [(0, 1), (1, 2), (2, 3)]
```

인덱스를 자동으로 부여해주기 때문에 매우 편리하게 사용 가능하다. 만약 `a = ['a', 'b', 'c']`의 리스트의 인덱스와 값을 함께 출력하려면 어떻게 해야할까? 

```python
# Step 1 (General)
for i in range(len(a)):
  	print(i, a[i])
    
# Step 2 (Not bad)
i = 0
for v in a:
  	print(i, v)
    i += 1
    
# Step 3 (Use enumrate, Good)
for i, v in enumerate(a):
		print(i, v)
```

`enumerate`를 통해 아주 깔끔하게 인덱스와 값을 함께 출력할 수 있다.

---

## print

가장 자주 쓰는 명령 중 하나로 여러 사용법을 정리해본다.

#### `sep`파라미터로 구분자를 지정

```python
print('a', 'b', sep=",")	# a,b
```

#### `end`파라미터로 줄바꿈 없이 출력

```python
print('a', end=' ')
print('b')	# a b
```

#### `join()`을 통해 리스트를 출력

```python
a = ['a', 'b']
print(' '.join(a))	# a b
```

#### f-string(formatted string literal)

변수를 뒤에 별도로 부여할 필요 없이 인라인으로 삽입할 수 있어 편리하다. 다른 방식에 비해 훨씬 간결하고 직관적이며 속도도 빠르다.

```python
idx = 1
fruit = "Apple"
print(f'{idx + 1}: {fruit}')	# 2: Apple
```

다만 f-string은 파이썬 3.6 이상에서만 지원한다. 

---

## pass

파이썬에서 `pass`는 널 연산(Null Operation)으로 아무것도 하지 않는 기능이다. `pass`를 통해 먼저 mockup 인터페이스부터 구현한 다음 추후 구현을 진행할 수 있게 한다.

```python
class Myclass(object):
  	def method_one(self):
      	pass	# 만약 pass가 없다면, 인덴트 오류가 발생
      
    def method_two(self):
      print("Two")
      
c = MyClass()
```





