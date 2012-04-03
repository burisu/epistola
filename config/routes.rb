Epistola::Application.routes.draw do
  
  match 'definir-colonnes/:file_id' => 'cleaner#columns', :via => [:get, :post]

  root :to => 'cleaner#upload'
end
