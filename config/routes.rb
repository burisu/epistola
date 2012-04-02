Epistola::Application.routes.draw do
  
  match 'definir-colonnes/:file_id' => 'cleaner#columns', :via => [:get, :post]
  match 'exporter-routage/:file_id' => 'cleaner#export', :via => [:get, :post]

  root :to => 'cleaner#upload'
end
