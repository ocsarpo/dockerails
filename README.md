# DockeRails

도커를 사용한 레일즈 프로젝트

- Dockerfile
  - Dockerfile로 레일즈 컨테이너 실행
  - .dockerignore로 이미지 최적화
  - 캐싱으로 이미지 최적화
  - 라벨링
  ```
  docker build -t railsapp .

  docker run -p 3000:3000 railsapp
  ```