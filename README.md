# 펌프 오일 체크리스트 Firebase 배포

이 폴더는 정적 HTML 앱을 Firebase Hosting으로 배포하고, GitHub push 시 자동 배포되도록 구성되어 있습니다.

## Firebase에서 켤 것

1. Firebase 프로젝트를 만들고 Web app을 추가합니다.
2. Authentication에서 Email/Password 로그인을 활성화하고 사용할 계정을 만듭니다.
3. Firestore Database를 생성합니다.
4. Firestore Rules에 `firestore.rules`를 배포합니다.

## GitHub Secret

GitHub 저장소의 `Settings > Secrets and variables > Actions`에 아래 값만 추가합니다.

- `FIREBASE_TOKEN`

`FIREBASE_TOKEN`은 Firebase CLI 로그인으로 만든 CI 토큰입니다. 토큰은 저장소 파일에 넣지 말고 GitHub Actions Secret에만 저장하세요.

## 로컬에서 먼저 확인

`public/firebase-config.js`에는 `pump-management-99364` 웹앱 설정이 들어 있습니다. Firebase 로그인 전에는 브라우저 localStorage에만 저장되고, 로그인 후 Firestore에 동기화됩니다.

Firebase CLI로 직접 배포하려면 `.firebaserc.example`을 `.firebaserc`로 복사한 뒤 프로젝트 ID를 바꾸고 `firebase deploy`를 실행하면 됩니다.

## 배포 흐름

GitHub 저장소의 `main` 브랜치로 push하면 `.github/workflows/firebase-hosting.yml`이 실행되고 Firebase Hosting의 live 채널로 배포됩니다.
