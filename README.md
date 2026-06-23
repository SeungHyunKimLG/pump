# 펌프 오일 체크리스트 Firebase 배포

이 폴더는 정적 HTML 앱을 Firebase Hosting으로 배포하고, GitHub push 시 자동 배포되도록 구성되어 있습니다.

## Firebase에서 켤 것

1. Firebase 프로젝트를 만들고 Web app을 추가합니다.
2. Authentication에서 Anonymous 로그인을 활성화합니다.
3. Firestore Database를 생성합니다.
4. Firestore Rules에 `firestore.rules`를 배포합니다.

## GitHub Secret

GitHub 저장소의 `Settings > Secrets and variables > Actions`에 아래 값만 추가합니다.

- `FIREBASE_SERVICE_ACCOUNT`

`FIREBASE_SERVICE_ACCOUNT`는 Firebase 프로젝트 설정의 서비스 계정 JSON 전체 내용입니다. JSON 파일 자체는 저장소에 올리지 마세요.

## 로컬에서 먼저 확인

`public/firebase-config.js`의 `PASTE_...` 값을 실제 Firebase 웹앱 설정으로 바꾸면 로컬에서도 Firestore 저장을 테스트할 수 있습니다. 그대로 두면 브라우저 localStorage에만 저장됩니다.

Firebase CLI로 직접 배포하려면 `.firebaserc.example`을 `.firebaserc`로 복사한 뒤 프로젝트 ID를 바꾸고 `firebase deploy`를 실행하면 됩니다.

## 배포 흐름

GitHub 저장소의 `main` 브랜치로 push하면 `.github/workflows/firebase-hosting.yml`이 실행되고 Firebase Hosting의 live 채널로 배포됩니다.
# pump
