+++
title = "[Github] Contribution이 Graph에 반영되지 않은 경우"
date = 2021-04-21T19:03:13+09:00
tags = ["github"]
categories = ["devnote"]
draft = false

+++

## Intro

가뭄에 콩 나듯 보이던 내 소중한 잔디들. 최근 블로그, 개인프로젝트, 이직 등의 이유로 github 활동을 다시 시작했다. 그런데 분명 commit을 했는데도 contribution에 반영이 안되는 경우가 종종 발생했다. 처음엔 집계가 되는 시간이 있나보다하고 넘어갔었는데 시간이 지나도 변하지 않아 문제 원인을 찾아보았다. 

이유는 바로, **로컬 상에 git 사용자 이메일 설정을 해놓지 않아서**였다. 정확히는 git commit을 날리는 local 상 사용자 이메일 설정이 Github계정의 이메일과 일치하지 않아서였다.

맥북을 교체하고 git 기본 설정을 제대로 해주지 않아 맥북으로 작업을 할때는 Contribution에 반영이 되지 않았던 것이다. Contribute로 인정 받지 못한(?) 이전 작업들이 조금 아깝지만 늦게라도 알아서 다행이다. 이번 기회에 `Github Contribution의 조건`이 어떻게 되는지 정리해본다.

[Github 문서](https://docs.github.com/en/github/setting-up-and-managing-your-github-profile/why-are-my-contributions-not-showing-up-on-my-profile) 에 따르면 Contribution의 조건은 아래와 같다.

## Contribution의 조건

### 1. Issues, pull requests, discusstions

- 신규 issue를 작성
- 신규 discusstion을 작성
- discusstion에 답변
- Pull Requests 날리기
- Pull Requests 리뷰 제출



### 2. Commit

기본적으로 아래의 조건을 만족하는 commit은 모두 Contribution에 집계된다.

- commit 시 사용되는 이메일이 Github 계정 이메일과 일치해야 함
- fork한 레파지토리가 아닌 독립적인 레파지토리에 대한 commit이어야 함
- 레파지토리의 default 브랜치(보통 master 이나 main)에서 생성된 commit이어야 함
- 혹은 `gh-pages` 브랜치에서 생성된 commit (프로젝트 페이지를 위한 레파지토리)



### 3. Others

- 레파지토리의 collaborator가 되거나 organization의 멤버가 되었을 때
- 내 레파지토리가 fork 되었을 때
- 내 레파지토리에 star를 받았을 때



Contribution 집계에 대한 꽤나 상세한 조건이 있다. 그럼 문서에서 설명하는 Contribution으로 집계되지 않는 이유에 대해 알아본다.

## Contribution으로 집계되지 않는 일반적인 이유들

### 1. 생성된지 24시간이 지나지 않은 commit

commit이 생성되고 Contribution으로 집계되기 까지 여러 조건을 확인해야한다. 따라서 commit은 최대 24시간이 지난 이후 graph에 반영된다.



### 2. 로컬 commit 이메일이 계정에 연결되지 않은 경우

commit은 Github계정에 연결된 이메일로 만들어지거나 github에서 제공되는 `noreply` 이메일로 생성되어야 한다. (`noreply` 이메일은 계정 이메일을 private으로 설정할 때 제공되는 이메일)



### 3. default (master, main) 이나 `gh-pages` 브랜치로 만들어진 commit이 아닌 경우

default 나 `gh-pages` 브랜치로 생성된 commit 만이 Contribution으로 집계된다. 만약 다른 브랜치로 커밋을 생성하고 Contribution으로 집계를 원하는 경우 아래 작업이 필요하다.

- pull request를 만들어 default 나 `gh-pages` 브랜치로 merge
- 레파지토리의 default 브랜치를 변경



### 4. fork 된 레파지토리에서 생성된 commit

fork된 레파지토리에서 생성된 commit은 Contribution으로 집계되지 않는다. 만약 집계를 원하는 경우 아래 작업이 필요하다.

- pull request를 만들어 원본 레파지토리에서 merge
- Github Support에 연락해 fork된 레파지토리를 독립 레파지토리로 detach (~~이렇게 까지..?~~)



## Outro

이 글을 통해 우리의 `소중한 잔디`를 본인도 모르게 흘려버리는 일이 없었으면 한다. (~~나처럼...~~)

로컬 상에 git 사용자 설정은 아래처럼 할 수 있다.

```bash
# set user name & email
git config --global user.name "username"
git config --global user.email "email@example.com"

# check user setting
git config --global user.name
git config --global user.email
```

[Github 문서 참고](https://docs.github.com/en/github/setting-up-and-managing-your-github-user-account/setting-your-commit-email-address#about-commit-email-addresses)

이제 열심히 잔디를 심어보자 :)