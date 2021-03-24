+++
title = "[알고리즘] Leetcode: Valid Palindrome"
date = 2021-03-24T21:14:21+09:00
tags = ["algorithm", "python"]
categories = ["devnote"]

+++

> `팰린드롬` 이란 뒤집어도 같은 말이 되는 단어 또는 문장을 의미한다. 대표적인 예로 `소주 만 병만 주소` 

## 문제

주어진 문자열이 팰린드롬인지 확인하라. 대소문자를 구분하지 않으며, 영문자와 숫자만을 대상으로 한다.

- 입력

```
"A man, a plan, a canal: Panama"
```

- 출력

```
true
```

## 풀이

### 1. 리스트로 변환

```python
def sol(self, s: str) -> bool:
		strs = []
    
    # 문제의 제약 조건에 대한 전처리로, 문자열 중 숫자/영문자가 아닌 문자들만 소문자로 변환하여 리스트에 저장
    for char in s:
      	if char.isalnum():
        		strs.append(char.lower())
    
		# 팰린드롬 여부 판별
    while len(strs) > 1:
      	if strs.pop(0) != strs.pop():
          	return False
    
    return True
```

해당 풀이의 핵심은 

- 맨 앞과 뒤를 한 글자씩 비교하면서 팰린드롬 여부를 판별하는 것
- 리스트의 `pop()`함수를 이용
  - `pop()`: 스택 형태로 마지막 요소를 전달하고 삭제
  - `pop(0)`: 큐 형태로 처음 요소를 전달하고 삭제

### 2. 데크 자료형을 이용한 최적화

```python
def sol(self, s: str) -> bool:
  	strs: Deque = collections.deque()
      
    for char in s:
      	if char.isalnum():
          	strs.append(char.lower())
            
    while len(strs) > 1:
      	if strs.popleft() != strs.pop():
          	return False
          
    return True
```

1번과 풀이 과정은 거의 동일하다. 하지만 여기서는 문자열을 리스트가 아닌 `collection.deque`로 사용하였다. 이는 속도면에서 큰 차이가 있는데 리스트의 `pop(0)`의 경우 O(n)인 반면, 데크 자료형의 `popleft()`는 O(1)이기 때문에 차이가 크다. 

리스트의 `pop(0)`은 성능면에서 다소 단점이 있으니 큐의 형태가 필요하다면 `collection.deque`를 사용하자.

### 3. 슬라이싱 이용

```python
def sol(self, s: str) -> bool:
  	s = s.lower()
    
    # 정규식으로 불필요 문자 필터링
    s = re.sub('[^a-z0-9]', '', s)
    
    return s == s[::-1]
```

사실 이 문제의 가장 단순한 해결 방법은 실제 문자를 뒤집어 비교하는 것이다. 리스트의 `reverse()`를 사용할 수도 있지만 그건 원본 리스트를 뒤집는 것이기 때문에 원본을 따로 저장해둬야해서 공간복잡도 면에서 불리하다. 이때 `슬라이싱`을 이용하면 위와 같이 아주 깔쌈하게 해결할 수 있다.

문자열 슬라이싱은 내부적으로 매우 빠르게 동작한다. 문자열을 별도 리스트로 매핑하는 과정에서 다른 연산 비용이 필요하므로 **문자열을 조작할 때는 항상 슬라이승을 우선으로 사용하는 편이 속도 개선에 유리하다.**

`[::-1]` 뒤집기! 그냥 외워버려 !