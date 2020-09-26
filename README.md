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

- docker-compose
  - docker-compose.yml로 앱 실행하기
  - 로컬 시스템 마운팅을 통한 일반적인 개발환경 세팅
  ```
  # docker compose 로 이미지빌드/컨테이너실행
  docker-compose up -d

  # 컨테이너 종료
  docker-compose stop
  # 혹은
  docker-compose stop <service_name>

  # 컨테이너 로그 보기
  docker-compose logs -f web

  # 실행중인 컨테이너에 추가적인 명령 실행하는 방법
  # 첫번 째, 일회성 컨테이너 사용하기
  docker-compose run --rm web echo 'ran a different command'

  # 두번 째, 실행 중인 컨테이너에 의존하여, 그 위에서 명령 실행하기
  docker-compose exec web echo 'ran a different command'

  # 이미지 다시 빌드하기
  docker-compose build web

  # 사용하지 않는 이미지, 컨테이너 삭제하기
  docker image prune
  docker container prune
  
  # 모든 리소스 해제
  docker system prune  
  ```
  