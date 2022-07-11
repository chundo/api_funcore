# frozen_string_literal: true

require 'functions_framework'

class Api::V1::HomeController < AppController
  # before_action :doorkeeper_authorize!, except: %i[shopify_products shopify_create_product shopify_product shopify_update_product shopify_create_checkout]
  # before_action :set_user, except: %i[shopify_products shopify_create_product shopify_product shopify_update_product shopify_create_checkout]
  before_action :shopify

  def shopify_products
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )

    products = ShopifyAPI::Product.all(
      session: session
    )

    render json: { products: products }, status: :ok
  end

  def shopify_create_product
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )
    product = ShopifyAPI::Product.new(session: session)
    product.title = 'Burton Custom Freestyle 151'
    product.body_html = '<strong>Good snowboard!</strong>'
    product.vendor = 'funcore'
    product.product_type = 'donation'
    product.images = [
      {
        'src' => 'http://example.com/rails_logo.gif'
      }
    ]
    product.tags = [
      'Barnes & Noble',
      'Big Air',
      "John's Fav"
    ]
    product.variants = [
      {
        'option1' => 'First',
        'price' => '10.00',
        'sku' => '123'
      },
      {
        'option1' => 'Second',
        'price' => '20.00',
        'sku' => '123'
      }
    ]
    product.save
    render json: { product: product }, status: :ok
  end

  def shopify_product
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )
    product = ShopifyAPI::Product.find(
      session: session,
      id: params[:id]
    )
    render json: { product: product }, status: :ok
  end

  def shopify_update_product
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )

    product = ShopifyAPI::Product.new(session: session)
    product.id = params[:id].to_i
    product.title = 'New product title'
    product.save

    render json: { product: product }, status: :ok
  end

  def shopify_disable_product
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )

    product = ShopifyAPI::Product.new(session: session)
    product.id = params[:id].to_i
    product.status = 'archived'
    product.save

    render json: { product: product }, status: :ok
  end

  def shopify_delete_product
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )

    ShopifyAPI::Product.delete(
      session: session,
      id: params[:id].to_i
    )

    render json: { product: 'Product Delete' }, status: :ok
  end

  def shopify_create_order
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )

    order = ShopifyAPI::Order.new(session: session)
    order.email = 'foo@example.com'
    order.fulfillment_status = 'fulfilled'
    order.send_receipt = false
    order.send_fulfillment_receipt = false
    order.line_items = [
      {
        'variant_id' => params[:id].to_i,
        'quantity' => 1
      }
    ]
    order.save

    render json: { order: order }, status: :ok
  end

  def shopify_orders
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )
    orders = ShopifyAPI::Order.all(
      session: session,
      status: 'any'
    )

    render json: { orders: orders }, status: :ok
  end

  def shopify_order
    session = ShopifyAPI::Auth::Session.new(
      shop: "#{ENV['SHOPIFY_SHOP_NAME']}.myshopify.com",
      access_token: ENV['SHOPIFY_TOKEN']
    )
    order = ShopifyAPI::Order.find(
      session: session,
      id: params[:id]
    )

    render json: { order: order }, status: :ok
  end

  def index
    date = I18n.l Time.now
    hello = I18n.t 'hello'

    render json: { message: %(#{hello} v1), date: date }, status: :ok
  end

  def querrys
    puts '-----------------'

    roles = Role.limit(10)

    roles.each do |role|
      puts role.user_roles
    end

    puts '*******************'

    roless = Role.limit(10)

    roless.each do |role|
      role.user_roles.each do |_role_|
        puts role
      end
    end

    puts '+++++++++++++++++++++++1'

    rolesss = Role.take(2)
    puts rolesss.to_json

    puts '+++++++++++++++++++++++2'

    rolessss = Role.find_by!(id: 1)
    puts rolessss.to_json

    puts '+++++++++++++++++++++++3'
    # Hace consultas en lotes de 100
    Role.find_each(batch_size: 100) do |role|
      puts role
    end

    puts '+++++++++++++++++++++++4'
    # Hace consultas en lotes de 100
    Role.find_in_batches(batch_size: 100) do |role|
      puts role
    end

    puts '+++++++++++++++++++++++5'
    # Selecciono solo un registro con el valor distinct
    puts Role.select(:id, :active).distinct.to_json

    puts '+++++++++++++++++++++++6'
    puts UserRole.select('role_id').group('role_id').to_json

    puts '+++++++++++++++++++++++7'
    puts UserRole.group(:active).count

    puts '+++++++++++++++++++++++8'
    puts UserRole.select('created_at, sum(id) as total_price')
                 .group('created_at').having('sum(id) > ?', 2)

    puts '+++++++++++++++++++++++9'
    # Agrupo y sumo valores que deseo
    roles_total = UserRole.select('created_at, sum(id) as total_price')
                          .group('created_at')
                          .having('sum(created_at) > ?', 1)
    puts roles_total[1].total_price

    puts '+++++++++++++++++++++++10'
    puts Role.joins(:user_roles).includes(:user_roles)

    puts '+++++++++++++++++++++++11'
    roles = Role.limit(10)

    roles.each do |role|
      puts role.user_roles
    end

    puts '+++++++++++++++++++++++12'
    roles = Role.includes(:user_roles, :users).limit(10)

    roles.each do |role|
      puts role.user_roles.to_json
    end

    puts '+++++++++++++++++++++++13'
    roles = User.includes(roles: { permissions: [:my_model] }).find(1)
    puts roles

    puts '+++++++++++++++++++++++14'
    roles = User.includes(user_roles: { role: [:permissions] }) # .find(1)
    puts roles

    puts '+++++++++++++++++++++++15'
    # user = User.includes(:user_roles).where(role: { active_role: true })
    # puts user
    books = UserRole.preload(:role).limit(10)
    books.each do |book|
      puts book.role
    end

    puts '+++++++++++++++++++++++16'
    books = UserRole.eager_load(:role).limit(10)

    books.each do |book|
      puts book.role
    end

    puts '+++++++++++++++++++++++17'
    books = UserRole.active

    books.each do |book|
      puts book.role
    end

    puts '+++++++++++++++++++++++18'
    books = UserRole.user(1)
    puts books

    puts User.where(id: 1).explain

    # Imports the Google Cloud client library
    require 'google/cloud/storage'

    # Instantiates a client
    storage = Google::Cloud::Storage.new

    # The ID to give your GCS bucket
    # bucket_name = "your-unique-bucket-name"

    # Creates the new bucket
    bucket = storage.create_bucket 'alkanza'

    puts "Bucket #{bucket.name} was created."
  end

  private

  def shopify
    ShopifyAPI::Context.setup(
      api_key: ENV['SHOPIFY_API'],
      api_secret_key: ENV['SHOPIFY_PASSWORD'],
      host_name: ENV['SHOPIFY_SHOP_NAME'],
      scope: 'read_orders,read_products,etc',
      session_storage: ShopifyAPI::Auth::FileSessionStorage.new, # This is only to be used for testing, more information in session docs
      is_embedded: true, # Set to true if you are building an embedded app
      is_private: false, # Set to true if you are building a private app
      api_version: '2022-07' # The vesion of the API you would like to use
    )
  end
end
