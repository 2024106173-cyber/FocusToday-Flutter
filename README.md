# 오늘한눈 (Focus Today) · Flutter UX/UI Midterm

**수강생:** 전시우 (2024106173)  
**주제:** 1번, 할 일 관리 앱  
**비교 대상:** Google Tasks (Google Play)  
**프로젝트:** 기존 서비스와 독립적으로 만든 수업용 v2 UI 프로토타입

## 1. 핵심 기획

Google Tasks의 공개 리뷰에서 모바일 목록의 카테고리/섹션 시각 구분을 개선해 달라는 요청을 찾았다. **학생이 오늘 해야 할 일을 빠르게 스캔하는 화면**을 제안한다. 색상 외에 텍스트 라벨과 중요도 표시도 제공한다.

- 사용자: 수업, 과제, 생활 일정을 함께 관리하는 대학생
- 문제: 서로 다른 목록과 중요도가 한눈에 구분되기 어려움
- v2: 카테고리 색+글자, 우선순위 정렬, 빠른 추가, 완료함
- 범위: 화면·네비게이션·더미 인터랙션·로컬 GET. 실제 저장/로그인/결제 없음

## 2. 실행 안내

이 폴더는 Flutter 핵심 소스와 문서를 포함한다. Flutter SDK가 있는 컴퓨터에서 앱 플랫폼 파일을 생성한다.

### 터미널 A · 로컬 데이터 서버

~~~bash
cd mock_server
npm install
npm start
~~~

확인: http://localhost:3000/tasks

### 터미널 B · Flutter

~~~bash
flutter create . --platforms=android,web
flutter pub get
flutter run
~~~

Android 에뮬레이터는 10.0.2.2:3000, 웹은 localhost:3000을 기본 사용한다. macOS에서 iOS 빌드가 필요할 때는 별도로 iOS 플랫폼을 생성할 수 있다. 실제 기기는 같은 네트워크에 연결하고 컴퓨터 IP를 전달한다.

~~~bash
flutter run --dart-define=MOCK_BASE_URL=http://192.168.0.10:3000
~~~

이 IP는 예시로, 사용자 환경의 IP로 교체해야 한다.

**Android 개발용 HTTP:** flutter create 실행 후 android/app/src/main/AndroidManifest.xml에 Android INTERNET permission을 추가한다. 개발 중 로컬 HTTP를 사용한다면 application에 android:usesCleartextTraffic="true" 설정이 필요할 수 있다. 출시용 앱에는 적용하지 않는다.

### 1분 데모 순서

1. 정상 시작: json-server GET /tasks
2. 오늘 카드, 카테고리 색상, 중요도 확인
3. 빠른 추가 → 제목·카테고리·중요도 → 화면에 추가
4. 체크 완료 → 완료함 → 상세에서 완료 취소
5. 상단 ⋮ → 로딩/오류/빈 상태

변경 사항은 화면 상태(setState)에서만 적용된다. 서버에 GET 외의 요청을 보내지 않는다. 새로고침하면 db.json의 데이터로 돌아간다.

## 3. 프로젝트 파일

| 경로 | 내용 |
|---|---|
| lib/main.dart | Flutter UI, GET 요청 |
| mock_server/db.json | 더미 데이터 |
| mock_server/package.json | 로컬 서버 실행 |
| docs/01_리뷰분석.md | 리뷰 출처·날짜·유형 |
| docs/02_앱요약.md | 앱 목적·페르소나·v2 가치 |
| docs/03_사용자여정.md | 단계·감정 저점·4가지 확장 |
| docs/04_피쉬본_5Why.md | 원인 후보·우선순위 |
| docs/05_화면기획_P01-P10.md | 화면 ID·네비게이션·위젯 |
| docs/06_셀프논증.md | AI 반론과 검토용 재반박 |
| docs/07_prompt-log.md | AI 사용 과정 |
| docs/08_전후비교.md | v1/v2 비교 |
| docs/09_발표원고.md | 한국어 6분 발표 원고 |
| docs/10_제출체크리스트.md | GitHub/LMS 제출 체크 |

## 4. 증거, 범위, 한계

- [Google Tasks 원본](https://play.google.com/store/apps/details?hl=ko&id=com.google.android.apps.tasks) 열람: 2026-10-28
- 개별 리뷰 별점과 스토어 분포 이미지는 검색 가능한 텍스트에서 확인되지 않았다. 제출 전 **원본 화면을 대조하고 이름을 가린 캡처를 첨부**해야 한다.
- 사용자 테스트와 성능 실측을 수행했다고 주장하지 않는다. 개선 효과는 테스트 전 가설이다.
- 셀프논증의 '나의 재반박'은 발표자가 검토하고 자신의 판단으로 확정해야 하는 초안이다.

출처: [Flutter Networking](https://docs.flutter.dev/data-and-backend/networking), [http package](https://pub.dev/packages/http), [json-server](https://github.com/typicode/json-server).
## 데모 영상 (Demo Video)
https://drive.google.com/file/d/13H7xyj7dwVF6NevyRzA62bcBLqT6wdYs/view?usp=sharing
