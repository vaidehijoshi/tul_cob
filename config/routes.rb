Rails.application.routes.draw do


  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  root to: "catalog#index"

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resource :summon, only: [:index], as: 'summon', path: '/summon', controller: 'summon' do
    concerns :searchable
    #concerns :range_searchable
  end

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  Blacklight::Marc.add_routes(self)
  scope module: 'blacklight_alma' do
    get 'alma/availability' => 'alma#availability'
  end


  resources :bookmarks do
    concerns :exportable
    collection do
      delete 'clear'
    end
  end

  concern :searchable, Blacklight::Routes::Searchable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :exportable, Blacklight::Routes::Exportable.new


  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
  end

  resource :summon, only: [:index], as: 'summon', path: '/summon', controller: 'summon' do
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  
    # User Stuff
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    delete 'users/sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  authenticate do
    get 'users/account'
    get 'users/fines'
    get 'users/holds'
    get 'users/loans'
    post 'users/renew'
    post 'users/renew_selected'
    post 'users/renew_all'
  end


  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
