+++
title = "Hugo와 Github을 이용한 블로그 개설하기 - 1"
date = 2020-01-29T19:49:31+09:00
tags = [""]
categories = [""]
draft = true
+++

hugo와 github을 처음 시작하는 비전공자를 위한 튜토리얼

## 1. 두개의 repository 생성

- 블로그 Root 레파지토리
- github page 운용을 위한 레파지토리

## 2. github 커밋

- https://gohugo.io/hosting-and-deployment/hosting-on-github/#step-by-step-instructions
- 위에것 그대로 따라하기
- (주의) 레파지토리 생성 할때 README.md 함께 initialize 하기
- 그대로 고고씽

## 3. 글 쓰기 및 관리하기

- deploy.sh 하나 생성 후 두개 레파지토리 다 커밋하기
- 글 삭제는 public 에서 해당 글 디렉토리를 날려야 반영됨
- 글 수정은 content내의 md파일 수정 후 hugo 명령어를 통해 재빌드하면 됨
