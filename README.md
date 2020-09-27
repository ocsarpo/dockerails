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
  - Webpacker
    - webpack 설치를 위해 Dockerfile 수정
    - webpack gem install (이미 되어 있음)
    - rails webpacker:install (이미 되어 있음)
    - webpacker로 react 설치
    - webpack_dev_server 서비스 추가
    - Hello React!

    ```
    Dockerfile 수정,
    gem 'webpacker', '~> 4.0',
    
    docker-compose build web
    docker-compose stop web
    # 웹팩 설치
    docker-compose run web bin/rails webpacker:install
    리액트 설치
    docker-compose run web bin/rails webpacker:install:react
    
    # docker-compose.yml에 webpack_dev_server 서비스 추가
    # web 서비스에도 환경 추가하여 webpack-dev-server를 찾을 수 있도록 함
    # 서비스 재시작
    docker-compose up -d web

    # 새로운 서비스 실행
    docker-compose up -d webpack-dev-server

    # Hello React를 위한 컨트롤러/뷰 생성
    docker-compose exec web bin/rails g controller pages home

    sudo chown <user>:<user> -R .

    # app/views/pages/home.html.erb 수정
    # http://localhost:3000/pages/home 접속
    ```

  - RSpec
    - 젬 설치
    - RSpec 설치
    - User 모델에 대한 spec 생성
    - 밸리데이션 추가, 테스트    
    ```
    # 젬 추가 후
    # web 서비스 중지, 다시 빌드, 컨테이너 다시 생성
    docker-compose stop web
    docker-compose build web
    docker-compose up -d --force-recreate web

    # RSpec 설치
    docker-compose exec web bin/rails generate rspec:install

    # spec 구동
    docker-compose exec web bin/rails spec

    # User 모델 spec 생성
    docker-compose exec web bin/rails generate rspec:model user

    # 권한 주의
    sudo chown <user>:<group> -R .

    # spec/models/user_spec.rb 작성
    # spec 구동
    docker-compose exec web bin/rails spec

    # user.rb 밸리데이션 작성 후 다시 spec 구동
    ```
  - Capybara
    - 젬 설치
    - mkdir spec/system
    - spec/system/page_views_spec.rb 작성
    - rack_test 드라이버 사용하여 빠른 테스트
    - 자바스크립트에 의존하는 시스템 테스트 (셀레니움)
    - 셀레니움 젬 추가
    - 셀레니움 크롬 서비스 추가
    - Capybara 셀레니움 크롬 드라이버 등록
    - 헤드리스를 사용하여 빠른 테스트
    - Capybara 셀레니움 헤드리스 크롬 드라이버 등록
    ```
    # 젬 추가 후, 빌드,중지,다시생성
    docker-compose build web
    docker-compose stop web
    docker-compose up -d --force-recreate web

    mkdir spec/system
    # spec/system/page_views_spec.rb 생성, 작성
    # spec/rails_helper.rb 에 rack_test를 쓰도록 설정

    # 시스템 테스트 실행
    docker-compose exec web rspec spec/system/

    # JavaScript에 의존하는 테스트를 위해 welcome/index.html.erb 에 코드 추가
    # application.html.erb.에 추가

    # js: true 인 시스템 스펙 시나리오 추가
    # 셀레니움 젬 추가
    docker-compose build web
    docker-compose stop web
    docker-compose up -d --force-recreate web

    # docker-compose.yml에 selenium_chrome 서비스 추가
      - selenium_chrome 서비스, web에 셀레니움 크롬 컨테이너에서 접근할 포트 4000추가
    # 서비스 시작
    docker-compose up -d selenium_chrome

    # spec/support/capybara.rb 생성하고, 작성
    
    # 카피바라 드라이버를 RSpec에서 쓰기 위한 설정
    # spec/rails_helper.rb 수정
      -> capybara.rb 포함, js 시스템 테스트에 대한 설정 추가

    # 시스템 테스트 수행
    docker-compose exec web rspec spec/system/

    # VNC 클라이언트로 vnc://localhost:5900 으로 접속하면 *비번 secret*
    셀레니움 크롬 컨테이너 리눅스 데스크탑이 나오고
    시스템 테스트 시 브라우저가 나타났다 사라진다.

    # 헤드리스 브라우징

    # spec/support/capybara.rb에 헤드리스 크롬을 위한 드라이버 등록
    require "selenium/webdriver" 추가
    헤드리스크롬 드라이버 등록 코드 추가

    드라이버를 등록했으니 rails.helper.rb의 js: true인 설정을 해당 드라이버로 변경

    테스트 수행
    docker-compose exec web rspec spec/system/
    -> 좀 더 빠른 테스트 가능

    ```