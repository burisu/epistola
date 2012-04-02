class CleanerController < ApplicationController

  COLUMNS = [ :subscriber_id, 
              :subscription_id => [[:subscriber_id, :number]],
              :first_name,
              :last_name,
              :title,
              :full_name => [[:last_name, " ", :first_name]],
              :line_2,
              :line_3,
              :line_4,
              :line_5,
              :post_code_and_city => [[:post_code, " ", :city]],
              :post_code,
              :city
            ]




  EXPORT = [
            :subscription_id,
            :title,
            :full_name,
            :line_2,
            :line_3,
            :line_4,
            :post_code,
            :city
           ]



  def upload
    
  end

  def columns
    find_file
  end

  def export
    find_file
  end

  protected

  def find_file
    file_id = params[:id]
    @file = File.open(Rails.root.join('tmp', 'cleaner', "#{file_id}.csv"))
  end

end
