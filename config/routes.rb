Epistola::Application.routes.draw do
  match 'nouveau-fichier' => 'cleaner#add_file', :via=>[:get, :post, :put]
  root :to => 'cleaner#index', :via=>[:get, :post]
end
