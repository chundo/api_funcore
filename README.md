# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- for runing the jobs execute (bundle exec sidekiq)

- ### rails g scaffold Model value value_a --database namedatabase_multidb

- ### rails generate graphql:object model

## Role

- name:string
- code:string
- description:text
- active:boolean
- default:boolean

`rails g scaffold Role name code:string:index description:text active:boolean default:boolean`

## User

- email:string
- username:string
- phone:string||integer
- uuid:string
- pin:string
- referal_code:string||integer
- terms:boolean
- active:boolean
- verified_account:boolean
- ####token_notifications
- #####phone_number
- #####user_code

`rails g migration AddUsernameToUser username:string phone uuid:string pin:string referal_code:string active:boolean terms:boolean`

## UserRole

- role_id:reference
- user_id:reference
- admin_id:reference
- active:boolean
- is_expired:boolean
- expired_type:enum date/peticions/time/datatime
- expired_value:string 10/09/1990||100||15||11/09/11/10:50

`rails g scaffold UserRole role:references user:references admin:references active:boolean is_expired:boolean expired_type:string expired_value:string`

## MyModel

- name:string
- code:string
- value:string
- description:text
- active:boolean

`rails g scaffold MyModel name code value description:text active:boolean`

## Parameter

- name:string
- code:string
- description:text
- user_id:reference
- value:string
- my_model_id:reference
- active:boolean
- is_public:boolean

`rails g scaffold Parameter name code description:text user:references value my_model:references active:boolean is_public:boolean`

## Permission

- role_id:reference
- model_id:reference
- action:string||enum
- method:string||enum
- user_id:reference
- allow:boolean
- active:boolean
- public:boolean
- is_expired:boolean
- expired_type:string||enum date/peticions/time/datatime
- expired_value:string 10/09/1990||100||15||11/09/11/10:50

`rails g scaffold Permission role:references my_model:references action method allow:boolean public:boolean user:references active:boolean is_expired:boolean expired_type expired_value`

## Block

- role_id:reference
- model_id:reference
- action:string||enum
- method:string||enum
- user_id:reference
- allow:boolean
- active:boolean
- public:boolean
- is_expired:boolean
- expired_type:string||enum date/peticions/time/datatime
- expired_value:string 10/09/1990||100||15||11/09/11/10:50

`rails g scaffold Permission role:references my_model:references action method allow:boolean public:boolean user:references active:boolean is_expired:boolean expired_type expired_value`

### ----------------------------------------

## Integration

- name
- code
- description:text
- user:reference
- active:boolean
- service
- service_type
- auth_type
- value
- key
- secret
- url
- url_a
- response
- app_uuid
- email
- password
- token

## Statu

- name
- code
- description
- category
- my_model_id
- user_id
- active

`rails g scaffold Statu name code description:text category user:references my_model:references active:boolean`

## Country

- name
- code
- description
- cioc
- currency_code
- currency_name
- currency_symbol
- language_iso639
- language_name
- language_native_name
- image
- date_utc
- active

`rails g scaffold Country name code description:text cioc currency_code currency_name currency_symbol language_iso639 language_name language_native_name image date_utc active:boolean`

## Profile

- user
- name
- email
- phone_number
- gender
- address
- first_name
- last_name
- country
- birthday
- document_type
- document
- user_type
- city
- avatar

`rails g scaffold Profile name avatar:attachment user:references active:boolean`
