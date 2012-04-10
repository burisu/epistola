Epistola::Application.routes.draw do
  
  match 'definir-colonnes' => 'cleaner#columns', :via => [:get, :post]
  get 'nouveau-telechargement' => 'cleaner#add_upload'
  match 'nouveau-fichier' => 'cleaner#add_file'
  post 'exporter' => 'cleaner#export'

  root :to => 'cleaner#index'
end
