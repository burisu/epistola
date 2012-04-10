# encoding: utf-8
require 'csv'
require 'safe_string'

class ::Array

  def contains?(*items)
    options = {}
    options = items.delete_at(-1) if items[-1].is_a?(Hash)
    seek = items.dup
    count = seek.count
    self.each do |x|
      seek.delete(x)
    end
    if options[:count]
      return count - seek.size
    else
      return seek.empty?
    end
  end

end

class CleanerController < ApplicationController
  CSV = (::CSV.const_defined?(:Reader) ? ::FasterCSV : ::CSV).freeze

  COLUMNS = { 
    :__unused__ => ["— Non utilisé —", ""],
    :subscriber_id => ["N°Abonné", "N°Client", "NCLI", "Numéro"], 
    :subscription_id => ["N°Abonnement", "ID"],
    :first_name => ["Prénom"],
    :last_name => ["Nom de famille", "Nom"],
    :title => ["Titre/Civilités", "Titre", "Civilité", "Civilités"],
    :last_name_and_first_name => ["Nom de famille & prénom", "Nom de famille et prénom", "Nom et prénom", "Nom prénom", "L1"],
    :line_2 => ["Destinataire ou service", "Destinataire, service", "Adresse 1", "Ligne 2", "L2", "Complément", "CIDE"],
    :line_3 => ["Bâtiment, résidence, ZI...", "Bat, res, zi", "Adresse 2", "Ligne 3", "L3"],
    :line_4 => ["N° & voie", "N° et voie", "Adresse", "Adresse 3", "Ligne 4", "L4"],
    :line_5 => ["Mention spéciale ou lieu-dit", "Mention spéciale, lieu-dit", "Adresse 4", "Ligne 5", "L5"],
    :post_code_and_city => ["Code postal & ville", "Code postal et ville", "Code postal et commune", "CP Ville", "CP Commune", "Ligne 6", "L6"],
    :post_code => ["Code postal", "CP"],
    :city => ["Ville", "Commune"],
    :quantity => ["Nombre d'exemplaires", "Nb. ex.", "Nb. exemplaire", "Nb. exemplaires", "Quantité", "Quantités", "NBEX"]
  }.freeze

  EXPORT = [
            { :label => "ID",
              :name => :id,
              :quote => false,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:quantity, :subscription_id)
                  code << "line[:subscription_id].to_s.rjust(9, '0')+qindex.to_s.upcase.rjust(3, '0')"
                elsif headers.contains?(:subscriber_id)
                  code << "line[:subscriber_id].to_s.rjust(6, '0')+number_by_subscriber[line[:subscriber_id]].to_s.upcase.rjust(3, '0')"
                else
                  code << "number.to_s.rjust(6, '0')"
                end
                code = params[:subscriber_prefix].to_s.inspect+"+"+code if params[:subscriber_prefix]
                code
              end},
            { :label => "Titre",
              :name => :title,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:last_name_and_first_name, :title)
                  code << "(title=line[:title].to_s.strip.upper_ascii; (line[:last_name_and_first_name].to_s.strip.upper_ascii.match(/\\b\#{title}\\b/) ? '' : title))"
                elsif headers.contains?(:last_name, :title)
                  code << "(title=line[:title].to_s.strip.upper_ascii; (line[:last_name].to_s.strip.upper_ascii.match(/\\b\#{title}\\b/) ? '' : title))"
                elsif headers.contains?(:title)
                  code << "line[:title].to_s.strip.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            },
            { :label => "Nom Prénom",
              :name => :last_name_and_first_name,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:last_name_and_first_name)
                  code << "line[:last_name_and_first_name].to_s.strip.upper_ascii"
                elsif headers.contains?(:last_name, :first_name)
                  code << "(line[:last_name].to_s+' '+line[:first_name].to_s).strip.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            },
            { :label => "Adresse 1",
              :name => :line_2,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:line_2)
                  code << "line[:line_2].to_s.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            },
            { :label => "Adresse 2", # N° et voie
              :name => :line_3,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:line_3)
                  code << "line[:line_3].to_s.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            },
            { :label => "Adresse 3",
              :name => :line_4,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:line_4)
                  code << "line[:line_4].to_s.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            },
            { :label => "Adresse 4",
              :name => :line_5,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:line_5)
                  code << "line[:line_5].to_s.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            },
            { :label => "CP",
              :name => :post_code,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:post_code_and_city)
                  code << "line[:post_code_and_city].to_s.split(' ')[0].upper_ascii"
                elsif headers.contains?(:post_code)
                  code << "line[:post_code].to_s.strip.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            },
            { :label => "Ville",
              :name => :city,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:post_code_and_city)
                  code << "line[:post_code_and_city].to_s.split(' ')[1..-1].join(' ').upper_ascii"
                elsif headers.contains?(:city)
                  code << "line[:city].to_s.strip.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            }
           ].freeze






  def index
    params[:export_file] ||= "AA.ASC"
    params[:line_size] ||= 32
  end


  hide_action :new_upload
  def new_file()
    key = @@uploads.dup
    @@uploads.succ!
    return {:key => key, :label => "Fichier #{key}", :uploaded => false}
  end

  def add_file
    @columns_labels = COLUMNS.values.collect{|x| x[0]}
    @columns = COLUMNS.collect{|k,v| [v[0], k]}
    @reversed_columns = {}
    for key, labels in COLUMNS
      for label in labels
        @reversed_columns[label.codeize] = key
      end
    end

    file = {}
    upload = params[:file]
    if request.post?
      file[:uploaded] = true
      if upload[:data]
        files_dir = Rails.root.join('tmp', 'cleaner')
        FileUtils.mkdir_p(files_dir)
        file_id = Time.now.to_i.to_s(36)+rand.to_s[2..-1].to_i.to_s(36)[0..6]
        File.open(files_dir.join(file_id), "wb") {|f| f.write(upload[:data].read) }
        file = {:label => upload[:data].original_filename.to_s, :key => file_id, :uploaded => true}
        begin
          f = find_file(file_id)
          f.readline
        rescue Exception => e
          file[:error] = "Le fichier CSV est mal formaté (#{e.class.name}: #{e.message})"
          file[:uploaded] = false
        end
      else
        file = upload.symbolize_keys
        file[:error] = "Merci de fournir un fichier ou de supprimer la ligne"
        file[:uploaded] = false
      end

      if file[:uploaded]
        f = find_file(file[:key])
        file[:headers] = f.readline
        file[:first_line] = f.readline
      end

      @file = file
      respond_to do |format|
        format.js
        # format.html {render :partial=>"cleaner/file", :object => file}
      end
      return
    elsif request.put?
      file = upload.symbolize_keys
      f = find_file(file[:key])
      file[:headers] = f.readline
      file[:first_line] = f.readline
      file[:messages] = generate_data(file[:key], file[:columns], false)
    elsif request.delete?
      
    else
      #
      file = new_file
    end
    render :partial=>"cleaner/file", :object => file
  end






  @@uploads = "A" unless defined? @@uploads












  # Generate a new key for a new upload
  hide_action :new_upload
  def new_upload()
    key = @@uploads.dup
    @@uploads.succ!
    return {:key => key, :label => "Fichier #{key}", :uploaded => false}
  end

  # Configure list of listings to upload
  def upload
    @columns = COLUMNS.values.collect{|x| x[0]}
    @listings = []
    if request.post?
      for letter, upload in params[:uploads]
        listing = {}
        if upload[:uploaded].to_s == 'true'
          listing = upload.symbolize_keys
          listing[:uploaded] = true
        elsif upload[:data]
          files_dir = Rails.root.join('tmp', 'cleaner')
          FileUtils.mkdir_p(files_dir)
          file_id = Time.now.to_i.to_s(36)+rand.to_s[2..-1].to_i.to_s(36)[0..6]
          File.open(files_dir.join(file_id), "wb") {|f| f.write(upload[:data].read) }
          listing = {:label => upload[:data].original_filename.to_s, :key => file_id, :uploaded => true}
          begin
            file = find_file(file_id)
            file.readline
          rescue Exception => e
            listing[:error] = "Le fichier CSV est mal formaté (#{e.class.name}: #{e.message})"
            listing[:uploaded] = false
          end
        else
          listing = upload.symbolize_keys
          listing[:error] = "Merci de fournir un fichier ou de supprimer la ligne"
          listing[:uploaded] = false          
        end
        @listings << listing
      end
      unless @listings.detect{|x| !x[:uploaded]}
        listings = {}
        @listings.each_with_index{|l, i| listings[i] = {:key=>l[:key], :label=>l[:label]}}
        redirect_to :action=>:columns, :listings=>listings # .delete_if{|k,v| ![:key, :label].include?(k)}
      end
    else
      @listings << new_upload
    end
  end

  # Adds a new line for an upload
  def add_upload
    render :partial=>"cleaner/upload", :object => new_upload
  end

  # Configures columns of files
  def columns
    @matchings = []
    for key, matching in params[:listings] || params[:matchings]
      matching ||= {}
      matching[:key] = matching[:key]
      matching[:label] = matching[:label]
      file = find_file(matching[:key])
      matching[:headers] = file.readline
      matching[:first_line] = file.readline
      
      if request.post?
        matching[:messages] = generate_data(matching[:key], matching[:columns], false) unless params[:force_export]
      end
      
      @matchings << matching
    end
    


    # if params[:force_export] or messages.size.zero?
    #   data = generate_data(key, true)
    #   send_data(data, :type=>:text, :filename=>(params[:export_file]||'export.csv'))
    # end

    # @file = find_file
    # @headers = @file.readline
    params[:export_file] ||= "AA.ASC"
    params[:line_size] ||= 32
    # if request.post?
    #   @messages = generate_data(false) unless params[:force_export]
    #   if params[:force_export] or @messages.size.zero?
    #     data = generate_data(true)
    #     send_data(data, :type=>:text, :filename=>(params[:export_file]||'export.csv'))
    #   end
    # end
    # @first_line = @file.readline
    @columns = COLUMNS.collect{|k,v| [v[0], k]}
    @reversed_columns = {}
    for key, labels in COLUMNS
      for label in labels
        @reversed_columns[label.codeize] = key
      end
    end
  end

  protected


  def generate_data(key, columns, generate_else_test = true)
    file = find_file(key)
    file.readline
    headers = []
    for k, v in columns
      headers[k.to_i] = (v.match(/__unused__/) ? nil : v.to_sym)
    end
    data, line_number, number, number_by_subscriber = '', 1, 0, {}
    excep, messages = [], []
    data.force_encoding('US-ASCII')
    code, line = "", ""


    doubles = []
    sheaders = headers.compact.sort # {|a,b| a.to_s <=> b.to_s}
    sheaders.each_with_index{|x,i| doubles << x if x == sheaders[i+1]}
    unless doubles.empty?
      doubles = doubles.uniq.collect{|h| '<em>'+COLUMNS[h][0]+'</em>'}
      messages << "ERREUR : Des colonnes sont définies plusieurs fois (#{doubles.to_sentence})".html_safe
    end
    
    missing_columns = []

    # Last name & First name
    if headers.include?(:last_name_and_first_name)
      multicol = COLUMNS[:last_name_and_first_name][0]
      if headers.include?(:last_name)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:last_name][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
      if headers.contains?(:first_name)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:first_name][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
    elsif !headers.contains?(:last_name, :first_name)
      missing_columns << :last_name unless headers.include?(:last_name)
      missing_columns << :first_name unless headers.include?(:first_name)
    end

    # Post code & City
    if headers.include?(:post_code_and_city)
      multicol = COLUMNS[:post_code_and_city][0]
      if headers.include?(:post_code)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:post_code][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
      if headers.contains?(:city)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:city][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
    elsif !headers.contains?(:post_code, :city)
      missing_columns << :post_code unless headers.include?(:post_code)
      missing_columns << :city unless headers.include?(:city)
    end

    # Missing columns
    if missing_columns.size > 0
      messages << ("ERREUR : Des colonnes ne sont pas définies : "+missing_columns.collect{|c| '<em>'+COLUMNS[c][0]+'</em>'}.to_sentence).html_safe
    end
    
    return messages unless generate_else_test or messages.empty?
    
    line = "data"
    EXPORT.each_with_index do |column, index|
      line << " << ';'" if index > 0
      ncode = column[:normalize][headers, params]
      ncode =  '\'"\'+(' + ncode + ').gsub(/\"/, "\'\'")+\'"\'' if column[:quote]
      line << " << " + ncode
    end
    line << ' << "\n"'
    
    unless generate_else_test
      line_size = params[:line_size].to_i
      line_size = 38 if line_size.zero?
      line << "\n"
      for l in [:line_2, :line_3, :line_4, :line_5]
        if headers.include?(l)
          col = export_column(l)
          line << "if (x = (#{col[:normalize][headers, params]}).strip).size > #{line_size}\n"
          line << "  messages << \"L\#{line[:__LINE__]} : <em>#{col[:label]}</em> est sur plus de #{line_size} car. (\#{x.size} car. pour <em>\#{x}</em>).\".html_safe\n"
          line << "end\n"
        end
      end
      col1 = export_column(:title)
      col2 = export_column(:last_name_and_first_name)
      line << "if (x = (#{col1[:normalize][headers, params]}+' '+#{col2[:normalize][headers, params]}).strip).size > #{line_size}\n"
      line << "  messages << \"L\#{line[:__LINE__]} : <em>#{col1[:label]} #{col2[:label]}</em> est sur plus de #{line_size} car. (\#{x.size} car. pour <em>\#{x}</em>).\".html_safe\n"
      line << "end\n"

      col1 = export_column(:post_code)
      col2 = export_column(:city)
      line << "if (x = (#{col1[:normalize][headers, params]}+' '+#{col2[:normalize][headers, params]}).strip).size > #{line_size}\n"
      line << "  messages << \"L\#{line[:__LINE__]} : <em>#{col1[:label]} #{col2[:label]}</em> est sur plus de #{line_size} car. (\#{x.size} car. pour <em>\#{x}</em>).\".html_safe\n"
      line << "end\n"
    end



    if headers.include?(:quantity)
      line = "number_by_subscriber[line[:subscriber_id]] = (number_by_subscriber[line[:subscriber_id]] || 0) + 1\n" + line if headers.include?(:subscriber_id)
      line = "number += 1\n" + line
      line = "line[:quantity].to_i.times do |qindex|\n"+line.strip.gsub(/^/, '  ')+"\nend\n"
    end

    code << "data=''\n"
    code << "for line_array in file.readlines\n"
    code << "  line_number += 1\n"
    code << "  line = {:__LINE__ => line_number"
    headers.each_with_index do |h,i| 
      code << ", :#{h} => line_array[#{i}]" unless h.nil?
    end
    code << "}\n"
    code << "  excep << line[:__LINE__] if [line[:line_2], line[:line_3], line[:line_4], line[:line_5]].collect{|x| (x.blank? ? nil : x)}.compact.size > 3\n"
    
    unless headers.include?(:quantity)
      code << "  number += 1\n"
      code << "  number_by_subscriber[line[:subscriber_id]] = (number_by_subscriber[line[:subscriber_id]] || 0) + 1\n" if headers.include?(:subscriber_id)
    end
    code << line.strip.gsub(/^/, '  ')+"\n"
    code << "end\n"
    # code.split(/\n/).each_with_index{|l,i| puts((i+1).to_s.rjust(4)+": "+l)}
    eval(code)
    if generate_else_test
      return data
    else
      return messages
    end
  end

  def export_column(name)
    return EXPORT.select{|h| h[:name] == name}[0]
  end

  def find_file(id=nil)
    file_id = id || params[:file_id]
    file = Rails.root.join('tmp', 'cleaner', file_id)
    unless File.exist?(file)
      raise Exception.new("No file #{file.to_s}")
    end
    return CSV.open(file, 'rb:utf-8')
  end

end
