ActionController::Routing::Routes.draw do |map|
  map.resources :api_keys

  map.resources :sites

  map.resources :action_types

  map.resources :action_sources

  map.resources :users

  map.resource :login


  map.namespace :shorturl do |shorturl|
    shorturl.resources :redirects, :collection => {:slug => :get}
    shorturl.resources :logs, :collection => {:hits => :get, :referrers => :get}
  end

  map.slug '/s/:slug', :controller => 'shorturl/redirects', :action => 'url'

  map.connect '/shorturl/logs/:slug/hits', :controller => 'shorturl/logs', :action => 'hits'
  map.connect '/shorturl/logs/:slug/hits.:format', :controller => 'shorturl/logs', :action => 'hits'

  map.connect '/shorturl/logs/:slug/referrers', :controller => 'shorturl/logs', :action => 'referrers'
  map.connect '/shorturl/logs/:slug/referrers.:format', :controller => 'shorturl/logs', :action => 'referrers'

  # Actually, the actions that modify the action should all be POST!
  map.resources :actions, :member => {:enable => :put, :disable => :put,
    :new_entity => :get, :create_entity => :put,
    :edit_entity => :get, :update_entity => :put,
    :delete_entity => :delete, :rescan => :put}
  #map.resources :tags, :map, :donations
  map.resources :tags

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)
  map.random '/random', :controller => 'actions', :action => 'random'
  map.access_denied '/access_denied', :controller => 'api_keys', :action => 'access_denied'
  map.access_denied '/access_denied.:format', :controller => 'api_keys', :action => 'access_denied'
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect '', :controller => 'actions', :action => 'index'
end
#== Route Map
# Generated on 23 Sep 2010 09:35
#
#                          api_keys GET    /api_keys                              {:action=>"index", :controller=>"api_keys"}
#                formatted_api_keys GET    /api_keys.:format                      {:action=>"index", :controller=>"api_keys"}
#                                   POST   /api_keys                              {:action=>"create", :controller=>"api_keys"}
#                                   POST   /api_keys.:format                      {:action=>"create", :controller=>"api_keys"}
#                       new_api_key GET    /api_keys/new                          {:action=>"new", :controller=>"api_keys"}
#             formatted_new_api_key GET    /api_keys/new.:format                  {:action=>"new", :controller=>"api_keys"}
#                      edit_api_key GET    /api_keys/:id/edit                     {:action=>"edit", :controller=>"api_keys"}
#            formatted_edit_api_key GET    /api_keys/:id/edit.:format             {:action=>"edit", :controller=>"api_keys"}
#                           api_key GET    /api_keys/:id                          {:action=>"show", :controller=>"api_keys"}
#                 formatted_api_key GET    /api_keys/:id.:format                  {:action=>"show", :controller=>"api_keys"}
#                                   PUT    /api_keys/:id                          {:action=>"update", :controller=>"api_keys"}
#                                   PUT    /api_keys/:id.:format                  {:action=>"update", :controller=>"api_keys"}
#                                   DELETE /api_keys/:id                          {:action=>"destroy", :controller=>"api_keys"}
#                                   DELETE /api_keys/:id.:format                  {:action=>"destroy", :controller=>"api_keys"}
#                             sites GET    /sites                                 {:action=>"index", :controller=>"sites"}
#                   formatted_sites GET    /sites.:format                         {:action=>"index", :controller=>"sites"}
#                                   POST   /sites                                 {:action=>"create", :controller=>"sites"}
#                                   POST   /sites.:format                         {:action=>"create", :controller=>"sites"}
#                          new_site GET    /sites/new                             {:action=>"new", :controller=>"sites"}
#                formatted_new_site GET    /sites/new.:format                     {:action=>"new", :controller=>"sites"}
#                         edit_site GET    /sites/:id/edit                        {:action=>"edit", :controller=>"sites"}
#               formatted_edit_site GET    /sites/:id/edit.:format                {:action=>"edit", :controller=>"sites"}
#                              site GET    /sites/:id                             {:action=>"show", :controller=>"sites"}
#                    formatted_site GET    /sites/:id.:format                     {:action=>"show", :controller=>"sites"}
#                                   PUT    /sites/:id                             {:action=>"update", :controller=>"sites"}
#                                   PUT    /sites/:id.:format                     {:action=>"update", :controller=>"sites"}
#                                   DELETE /sites/:id                             {:action=>"destroy", :controller=>"sites"}
#                                   DELETE /sites/:id.:format                     {:action=>"destroy", :controller=>"sites"}
#                      action_types GET    /action_types                          {:action=>"index", :controller=>"action_types"}
#            formatted_action_types GET    /action_types.:format                  {:action=>"index", :controller=>"action_types"}
#                                   POST   /action_types                          {:action=>"create", :controller=>"action_types"}
#                                   POST   /action_types.:format                  {:action=>"create", :controller=>"action_types"}
#                   new_action_type GET    /action_types/new                      {:action=>"new", :controller=>"action_types"}
#         formatted_new_action_type GET    /action_types/new.:format              {:action=>"new", :controller=>"action_types"}
#                  edit_action_type GET    /action_types/:id/edit                 {:action=>"edit", :controller=>"action_types"}
#        formatted_edit_action_type GET    /action_types/:id/edit.:format         {:action=>"edit", :controller=>"action_types"}
#                       action_type GET    /action_types/:id                      {:action=>"show", :controller=>"action_types"}
#             formatted_action_type GET    /action_types/:id.:format              {:action=>"show", :controller=>"action_types"}
#                                   PUT    /action_types/:id                      {:action=>"update", :controller=>"action_types"}
#                                   PUT    /action_types/:id.:format              {:action=>"update", :controller=>"action_types"}
#                                   DELETE /action_types/:id                      {:action=>"destroy", :controller=>"action_types"}
#                                   DELETE /action_types/:id.:format              {:action=>"destroy", :controller=>"action_types"}
#                    action_sources GET    /action_sources                        {:action=>"index", :controller=>"action_sources"}
#          formatted_action_sources GET    /action_sources.:format                {:action=>"index", :controller=>"action_sources"}
#                                   POST   /action_sources                        {:action=>"create", :controller=>"action_sources"}
#                                   POST   /action_sources.:format                {:action=>"create", :controller=>"action_sources"}
#                 new_action_source GET    /action_sources/new                    {:action=>"new", :controller=>"action_sources"}
#       formatted_new_action_source GET    /action_sources/new.:format            {:action=>"new", :controller=>"action_sources"}
#                edit_action_source GET    /action_sources/:id/edit               {:action=>"edit", :controller=>"action_sources"}
#      formatted_edit_action_source GET    /action_sources/:id/edit.:format       {:action=>"edit", :controller=>"action_sources"}
#                     action_source GET    /action_sources/:id                    {:action=>"show", :controller=>"action_sources"}
#           formatted_action_source GET    /action_sources/:id.:format            {:action=>"show", :controller=>"action_sources"}
#                                   PUT    /action_sources/:id                    {:action=>"update", :controller=>"action_sources"}
#                                   PUT    /action_sources/:id.:format            {:action=>"update", :controller=>"action_sources"}
#                                   DELETE /action_sources/:id                    {:action=>"destroy", :controller=>"action_sources"}
#                                   DELETE /action_sources/:id.:format            {:action=>"destroy", :controller=>"action_sources"}
#                             users GET    /users                                 {:action=>"index", :controller=>"users"}
#                   formatted_users GET    /users.:format                         {:action=>"index", :controller=>"users"}
#                                   POST   /users                                 {:action=>"create", :controller=>"users"}
#                                   POST   /users.:format                         {:action=>"create", :controller=>"users"}
#                          new_user GET    /users/new                             {:action=>"new", :controller=>"users"}
#                formatted_new_user GET    /users/new.:format                     {:action=>"new", :controller=>"users"}
#                         edit_user GET    /users/:id/edit                        {:action=>"edit", :controller=>"users"}
#               formatted_edit_user GET    /users/:id/edit.:format                {:action=>"edit", :controller=>"users"}
#                              user GET    /users/:id                             {:action=>"show", :controller=>"users"}
#                    formatted_user GET    /users/:id.:format                     {:action=>"show", :controller=>"users"}
#                                   PUT    /users/:id                             {:action=>"update", :controller=>"users"}
#                                   PUT    /users/:id.:format                     {:action=>"update", :controller=>"users"}
#                                   DELETE /users/:id                             {:action=>"destroy", :controller=>"users"}
#                                   DELETE /users/:id.:format                     {:action=>"destroy", :controller=>"users"}
#                                   POST   /login                                 {:action=>"create", :controller=>"logins"}
#                                   POST   /login.:format                         {:action=>"create", :controller=>"logins"}
#                         new_login GET    /login/new                             {:action=>"new", :controller=>"logins"}
#               formatted_new_login GET    /login/new.:format                     {:action=>"new", :controller=>"logins"}
#                        edit_login GET    /login/edit                            {:action=>"edit", :controller=>"logins"}
#              formatted_edit_login GET    /login/edit.:format                    {:action=>"edit", :controller=>"logins"}
#                             login GET    /login                                 {:action=>"show", :controller=>"logins"}
#                   formatted_login GET    /login.:format                         {:action=>"show", :controller=>"logins"}
#                                   PUT    /login                                 {:action=>"update", :controller=>"logins"}
#                                   PUT    /login.:format                         {:action=>"update", :controller=>"logins"}
#                                   DELETE /login                                 {:action=>"destroy", :controller=>"logins"}
#                                   DELETE /login.:format                         {:action=>"destroy", :controller=>"logins"}
#           slug_shorturl_redirects GET    /shorturl/redirects/slug               {:action=>"slug", :controller=>"shorturl/redirects"}
# formatted_slug_shorturl_redirects GET    /shorturl/redirects/slug.:format       {:action=>"slug", :controller=>"shorturl/redirects"}
#                shorturl_redirects GET    /shorturl/redirects                    {:action=>"index", :controller=>"shorturl/redirects"}
#      formatted_shorturl_redirects GET    /shorturl/redirects.:format            {:action=>"index", :controller=>"shorturl/redirects"}
#                                   POST   /shorturl/redirects                    {:action=>"create", :controller=>"shorturl/redirects"}
#                                   POST   /shorturl/redirects.:format            {:action=>"create", :controller=>"shorturl/redirects"}
#             new_shorturl_redirect GET    /shorturl/redirects/new                {:action=>"new", :controller=>"shorturl/redirects"}
#   formatted_new_shorturl_redirect GET    /shorturl/redirects/new.:format        {:action=>"new", :controller=>"shorturl/redirects"}
#            edit_shorturl_redirect GET    /shorturl/redirects/:id/edit           {:action=>"edit", :controller=>"shorturl/redirects"}
#  formatted_edit_shorturl_redirect GET    /shorturl/redirects/:id/edit.:format   {:action=>"edit", :controller=>"shorturl/redirects"}
#                 shorturl_redirect GET    /shorturl/redirects/:id                {:action=>"show", :controller=>"shorturl/redirects"}
#       formatted_shorturl_redirect GET    /shorturl/redirects/:id.:format        {:action=>"show", :controller=>"shorturl/redirects"}
#                                   PUT    /shorturl/redirects/:id                {:action=>"update", :controller=>"shorturl/redirects"}
#                                   PUT    /shorturl/redirects/:id.:format        {:action=>"update", :controller=>"shorturl/redirects"}
#                                   DELETE /shorturl/redirects/:id                {:action=>"destroy", :controller=>"shorturl/redirects"}
#                                   DELETE /shorturl/redirects/:id.:format        {:action=>"destroy", :controller=>"shorturl/redirects"}
#           referrers_shorturl_logs GET    /shorturl/logs/referrers               {:action=>"referrers", :controller=>"shorturl/logs"}
# formatted_referrers_shorturl_logs GET    /shorturl/logs/referrers.:format       {:action=>"referrers", :controller=>"shorturl/logs"}
#                hits_shorturl_logs GET    /shorturl/logs/hits                    {:action=>"hits", :controller=>"shorturl/logs"}
#      formatted_hits_shorturl_logs GET    /shorturl/logs/hits.:format            {:action=>"hits", :controller=>"shorturl/logs"}
#                     shorturl_logs GET    /shorturl/logs                         {:action=>"index", :controller=>"shorturl/logs"}
#           formatted_shorturl_logs GET    /shorturl/logs.:format                 {:action=>"index", :controller=>"shorturl/logs"}
#                                   POST   /shorturl/logs                         {:action=>"create", :controller=>"shorturl/logs"}
#                                   POST   /shorturl/logs.:format                 {:action=>"create", :controller=>"shorturl/logs"}
#                  new_shorturl_log GET    /shorturl/logs/new                     {:action=>"new", :controller=>"shorturl/logs"}
#        formatted_new_shorturl_log GET    /shorturl/logs/new.:format             {:action=>"new", :controller=>"shorturl/logs"}
#                 edit_shorturl_log GET    /shorturl/logs/:id/edit                {:action=>"edit", :controller=>"shorturl/logs"}
#       formatted_edit_shorturl_log GET    /shorturl/logs/:id/edit.:format        {:action=>"edit", :controller=>"shorturl/logs"}
#                      shorturl_log GET    /shorturl/logs/:id                     {:action=>"show", :controller=>"shorturl/logs"}
#            formatted_shorturl_log GET    /shorturl/logs/:id.:format             {:action=>"show", :controller=>"shorturl/logs"}
#                                   PUT    /shorturl/logs/:id                     {:action=>"update", :controller=>"shorturl/logs"}
#                                   PUT    /shorturl/logs/:id.:format             {:action=>"update", :controller=>"shorturl/logs"}
#                                   DELETE /shorturl/logs/:id                     {:action=>"destroy", :controller=>"shorturl/logs"}
#                                   DELETE /shorturl/logs/:id.:format             {:action=>"destroy", :controller=>"shorturl/logs"}
#                                          /s/:slug                               {:action=>"url", :controller=>"shorturl/redirects"}
#                                          /shorturl/logs/:slug/hits              {:action=>"hits", :controller=>"shorturl/logs"}
#                                          /shorturl/logs/:slug/hits.:format      {:action=>"hits", :controller=>"shorturl/logs"}
#                                          /shorturl/logs/:slug/referrers         {:action=>"referrers", :controller=>"shorturl/logs"}
#                                          /shorturl/logs/:slug/referrers.:format {:action=>"referrers", :controller=>"shorturl/logs"}
#                           actions GET    /actions                               {:action=>"index", :controller=>"actions"}
#                 formatted_actions GET    /actions.:format                       {:action=>"index", :controller=>"actions"}
#                                   POST   /actions                               {:action=>"create", :controller=>"actions"}
#                                   POST   /actions.:format                       {:action=>"create", :controller=>"actions"}
#                        new_action GET    /actions/new                           {:action=>"new", :controller=>"actions"}
#              formatted_new_action GET    /actions/new.:format                   {:action=>"new", :controller=>"actions"}
#                       edit_action GET    /actions/:id/edit                      {:action=>"edit", :controller=>"actions"}
#             formatted_edit_action GET    /actions/:id/edit.:format              {:action=>"edit", :controller=>"actions"}
#                            action GET    /actions/:id                           {:action=>"show", :controller=>"actions"}
#                  formatted_action GET    /actions/:id.:format                   {:action=>"show", :controller=>"actions"}
#                                   PUT    /actions/:id                           {:action=>"update", :controller=>"actions"}
#                                   PUT    /actions/:id.:format                   {:action=>"update", :controller=>"actions"}
#                                   DELETE /actions/:id                           {:action=>"destroy", :controller=>"actions"}
#                                   DELETE /actions/:id.:format                   {:action=>"destroy", :controller=>"actions"}
#                              tags GET    /tags                                  {:action=>"index", :controller=>"tags"}
#                    formatted_tags GET    /tags.:format                          {:action=>"index", :controller=>"tags"}
#                                   POST   /tags                                  {:action=>"create", :controller=>"tags"}
#                                   POST   /tags.:format                          {:action=>"create", :controller=>"tags"}
#                           new_tag GET    /tags/new                              {:action=>"new", :controller=>"tags"}
#                 formatted_new_tag GET    /tags/new.:format                      {:action=>"new", :controller=>"tags"}
#                          edit_tag GET    /tags/:id/edit                         {:action=>"edit", :controller=>"tags"}
#                formatted_edit_tag GET    /tags/:id/edit.:format                 {:action=>"edit", :controller=>"tags"}
#                               tag GET    /tags/:id                              {:action=>"show", :controller=>"tags"}
#                     formatted_tag GET    /tags/:id.:format                      {:action=>"show", :controller=>"tags"}
#                                   PUT    /tags/:id                              {:action=>"update", :controller=>"tags"}
#                                   PUT    /tags/:id.:format                      {:action=>"update", :controller=>"tags"}
#                                   DELETE /tags/:id                              {:action=>"destroy", :controller=>"tags"}
#                                   DELETE /tags/:id.:format                      {:action=>"destroy", :controller=>"tags"}
#                         map_index GET    /map                                   {:action=>"index", :controller=>"map"}
#               formatted_map_index GET    /map.:format                           {:action=>"index", :controller=>"map"}
#                                   POST   /map                                   {:action=>"create", :controller=>"map"}
#                                   POST   /map.:format                           {:action=>"create", :controller=>"map"}
#                           new_map GET    /map/new                               {:action=>"new", :controller=>"map"}
#                 formatted_new_map GET    /map/new.:format                       {:action=>"new", :controller=>"map"}
#                          edit_map GET    /map/:id/edit                          {:action=>"edit", :controller=>"map"}
#                formatted_edit_map GET    /map/:id/edit.:format                  {:action=>"edit", :controller=>"map"}
#                               map GET    /map/:id                               {:action=>"show", :controller=>"map"}
#                     formatted_map GET    /map/:id.:format                       {:action=>"show", :controller=>"map"}
#                                   PUT    /map/:id                               {:action=>"update", :controller=>"map"}
#                                   PUT    /map/:id.:format                       {:action=>"update", :controller=>"map"}
#                                   DELETE /map/:id                               {:action=>"destroy", :controller=>"map"}
#                                   DELETE /map/:id.:format                       {:action=>"destroy", :controller=>"map"}
#                         donations GET    /donations                             {:action=>"index", :controller=>"donations"}
#               formatted_donations GET    /donations.:format                     {:action=>"index", :controller=>"donations"}
#                                   POST   /donations                             {:action=>"create", :controller=>"donations"}
#                                   POST   /donations.:format                     {:action=>"create", :controller=>"donations"}
#                      new_donation GET    /donations/new                         {:action=>"new", :controller=>"donations"}
#            formatted_new_donation GET    /donations/new.:format                 {:action=>"new", :controller=>"donations"}
#                     edit_donation GET    /donations/:id/edit                    {:action=>"edit", :controller=>"donations"}
#           formatted_edit_donation GET    /donations/:id/edit.:format            {:action=>"edit", :controller=>"donations"}
#                          donation GET    /donations/:id                         {:action=>"show", :controller=>"donations"}
#                formatted_donation GET    /donations/:id.:format                 {:action=>"show", :controller=>"donations"}
#                                   PUT    /donations/:id                         {:action=>"update", :controller=>"donations"}
#                                   PUT    /donations/:id.:format                 {:action=>"update", :controller=>"donations"}
#                                   DELETE /donations/:id                         {:action=>"destroy", :controller=>"donations"}
#                                   DELETE /donations/:id.:format                 {:action=>"destroy", :controller=>"donations"}
#                            random        /random                                {:action=>"random", :controller=>"actions"}
#                                          /access_denied                         {:action=>"access_denied", :controller=>"api_keys"}
#                     access_denied        /access_denied.:format                 {:action=>"access_denied", :controller=>"api_keys"}
#                                          /:controller/:action/:id
#                                          /:controller/:action/:id.:format
#                                          /                                      {:action=>"index", :controller=>"actions"}
