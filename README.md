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
  
- add service
  - docker-compose에 새로운 서비스 redis 추가
  - Redis를 사용하여 Welcome#index 에 page hit 구현
  ```
  Gemfile에서
  gem 'redis', '~> 4.0' # 주석해제

  Gemfile을 수정했으니 이미지 다시 빌드
  docker-compose stop web (컨테이너 중지)
  docker-compose build web
  
  docker-compose ps (상태 확인)
  docker-compose up -d (컨테이너가 실행되지 않았다면.. )  
  docker-compose exec web bin/rails g controller welcome index
  ```
 - Postgres Database
   - gem install
   - config/database.yml 수정
   - 환경변수를 파일로 지정
   - User Scaffold
   - Named volume을 사용하여 데이터 영속화

   ```
   docker-compose stop web
   docker-compose build web
   docker-compuse up -d

   # db:create 하지 않는 이유는 postgres 서비스에서 
   # POSTGRES_DB 값을 테이블의 이름으로 사용하여 생성하기 때문이다.

   # Scaffold User
   docker-compose exec web \
       bin/rails g scaffold User first_name:string last_name:string

   #파일 권한 주의
   sudo chown <user>:<user> -R .

   # migration
   docker-compose exec web \
       bin/rails db:migrate
   # https://localhost:3000/users 에 접속

   # 영속화를 위한 docker-compose.yml에 volumes 설정 이후
   # 재시작! (별도 명령이 없으면 서비스에 대해 같은 컨테이너를 재사용하기 때문에)
   # 명시적으로 컨테이너를 재생성해야함
   docker-compose stop database
   docker-compose rm -f database

   docker-compose up -d database

   # 다 사라졌으므로 다시 마이그레이션
   docker-compose exec web bin/rails db:create db:migrate

   # 데이터가 저장되는 명명된 볼륨의 위치 확인
   docker volume inspect --format '{{ .Mountpoint }}' dockerails_db_data
   ```