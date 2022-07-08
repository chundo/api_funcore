# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Doorkeeper::Application.create(name: 'ideardev', redirect_uri: 'urn:ietf:wg:oauth:2.0:oob', scopes: [])

Role.create([
              {
                name: 'Default',
                code: 'DEFAULT',
                description: 'ok',
                active: true,
                default: true
              },
              {
                name: 'Users',
                code: 'USER',
                description: 'user role',
                active: true,
                default: false
              },
              {
                name: 'Super',
                code: 'SUPER',
                description: 'super role',
                active: true,
                default: false
              },
              {
                name: 'Admin',
                code: 'ADMIN',
                description: 'Administrator',
                active: true,
                default: false
              }
            ])

User.create(email: 'srespana1@gmail.gmail', password: 'sr123456', username: 'srespana1', phone: '528', uuid: 'uuid',
            active: true, terms: true, verified_account: true)

UserRole.create([
                  {
                    role_id: 1,
                    user_id: 1,
                    admin_id: 1,
                    active: true,
                    is_expired: false,
                    expired_type: false,
                    expired_value: '10'
                  },
                  {
                    role_id: 3,
                    user_id: 1,
                    admin_id: 1,
                    active: true,
                    is_expired: false,
                    expired_type: 'date',
                    expired_value: '10/09/2023'
                  },
                  {
                    role_id: 2,
                    user_id: 1,
                    admin_id: 1,
                    active: true,
                    is_expired: false,
                    expired_type: 'petitions',
                    expired_value: '2'
                  }
                ])

MyModel.create([
                 {
                   name: 'Home',
                   code: 'home',
                   value: 'home',
                   description: 'home model for controller and other actiones',
                   active: true
                 },
                 {
                   name: 'SchemaMigration',
                   code: 'SCHEMA_MIGRATIONS',
                   value: 'schema_migrations',
                   description: 'Model SchemaMigration',
                   active: true
                 },
                 {
                   name: 'ArInternalMetadatum',
                   code: 'AR_INTERNAL_METADATA',
                   value: 'ar_internal_metadata',
                   description: 'Model ArInternalMetadatum',
                   active: true
                 },
                 {
                   name: 'Role',
                   code: 'ROLES',
                   value: 'roles',
                   description: 'Model Role',
                   active: true
                 },
                 {
                   name: 'User',
                   code: 'USERS',
                   value: 'users',
                   description: 'Model User',
                   active: true
                 },
                 {
                   name: 'UserRole',
                   code: 'USER_ROLES',
                   value: 'user_roles',
                   description: 'Model UserRole',
                   active: true
                 },
                 {
                   name: 'MyModel',
                   code: 'MY_MODELS',
                   value: 'my_models',
                   description: 'Model MyModel',
                   active: true
                 },
                 {
                   name: 'Parameter',
                   code: 'PARAMETERS',
                   value: 'parameters',
                   description: 'Model Parameter',
                   active: true
                 },
                 {
                   name: 'Permission',
                   code: 'PERMISSIONS',
                   value: 'permissions',
                   description: 'Model Permission',
                   active: true
                 },
                 {
                   name: 'OauthApplication',
                   code: 'OAUTH_APPLICATIONS',
                   value: 'oauth_applications',
                   description: 'Model OauthApplication',
                   active: true
                 },
                 {
                   name: 'OauthAccessGrant',
                   code: 'OAUTH_ACCESS_GRANTS',
                   value: 'oauth_access_grants',
                   description: 'Model OauthAccessGrant',
                   active: true
                 },
                 {
                   name: 'OauthAccessToken',
                   code: 'OAUTH_ACCESS_TOKENS',
                   value: 'oauth_access_tokens',
                   description: 'Model OauthAccessToken',
                   active: true
                 },
                 {
                   name: 'Profile',
                   code: 'PROFILES',
                   value: 'profiles',
                   description: 'Model Profile',
                   active: true
                 },
                 {
                   name: 'Graphql',
                   code: 'graphql',
                   value: 'graphql',
                   description: 'graphql module',
                   active: true
                 }
               ])

Parameter.create([
                   {
                     name: 'NAME',
                     code: 'name',
                     description: 'Name project',
                     user_id: 1,
                     value: 'Idear Template',
                     my_model_id: 1,
                     active: false,
                     is_public: true
                   }
                 ])

Permission.create([
                    {
                      role_id: 2,
                      my_model_id: 5,
                      action: 'me',
                      method: 'GET',
                      allow: false,
                      public: false,
                      user_id: 1,
                      active: true,
                      is_expired: false,
                      expired_type: 'petitions',
                      expired_value: '300000'
                    },
                    {
                      role_id: 2,
                      my_model_id: 8,
                      action: 'index',
                      method: 'GET',
                      allow: false,
                      public: true,
                      user_id: 1,
                      active: true,
                      is_expired: false,
                      expired_type: 'petitions',
                      expired_value: '20'
                    },
                    {
                      role_id: 2,
                      my_model_id: 1,
                      action: 'index',
                      method: 'GET',
                      allow: false,
                      public: true,
                      user_id: 1,
                      active: true,
                      is_expired: false,
                      expired_type: 'date',
                      expired_value: '25/03/2022'
                    },
                    {
                      role_id: 2,
                      my_model_id: 5,
                      action: 'login',
                      method: 'POST',
                      allow: false,
                      public: true,
                      user_id: 1,
                      active: true,
                      is_expired: false,
                      expired_type: 'date',
                      expired_value: '17/03/2023'
                    },
                    {
                      role_id: 2,
                      my_model_id: 14,
                      action: 'execute',
                      method: 'POST',
                      allow: false,
                      public: false,
                      user_id: 1,
                      active: true,
                      is_expired: false,
                      expired_type: 'petitions',
                      expired_value: '50'
                    },
                    {
                      role_id: 2,
                      my_model_id: 4,
                      action: 'index',
                      method: 'GET',
                      allow: false,
                      public: false,
                      user_id: 1,
                      active: true,
                      is_expired: false,
                      expired_type: 'date',
                      expired_value: '16/03/2025'
                    }
                  ])
