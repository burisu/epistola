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
    :title => ["Titre/Civilités", "Titre", "Civilité", "Civilités"],
    :last_name_and_first_name => ["Nom de famille & prénom", "Nom de famille et prénom", "Nom et prénom", "Nom prénom", "L1"],
    :last_name => ["Nom de famille", "Nom"],
    :first_name => ["Prénom"],
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
                # # if headers.contains?(:quantity, :subscription_id)
                # #   code << "SUBSCRIPTION_ID.to_s.rjust(9, '0')+qindex.to_s.upcase.rjust(3, '0')"
                # # elsif headers.contains?(:subscriber_id)
                # #   code << "SUBSCRIBER_ID.to_s.rjust(6, '0')+number_by_subscriber[SUBSCRIBER_ID].to_s.upcase.rjust(3, '0')"
                # # else
                # code << "file_number.to_s.rjust(2, '0')[-2..-1]+number.to_s.rjust(6, '0')"
                code << "number.to_s.rjust(6, '0')"
                # end
                code = params[:subscriber_prefix].to_s.inspect+"+"+code unless params[:subscriber_prefix].blank?
                code
              end},
            { :label => "Titre",
              :name => :title,
              :quote => true,
              :normalize => Proc.new do |headers, params|
                code = ""
                if headers.contains?(:last_name_and_first_name, :title)
                  code << "(title=TITLE.to_s.strip.upper_ascii; (LAST_NAME_AND_FIRST_NAME.to_s.strip.upper_ascii.match(/\\b\#{title}\\b/) ? '' : title))"
                elsif headers.contains?(:last_name, :title)
                  code << "(title=TITLE.to_s.strip.upper_ascii; (LAST_NAME.to_s.strip.upper_ascii.match(/\\b\#{title}\\b/) ? '' : title))"
                elsif headers.contains?(:title)
                  code << "TITLE.to_s.strip.upper_ascii"
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
                  code << "LAST_NAME_AND_FIRST_NAME.to_s.strip.upper_ascii"
                elsif headers.contains?(:last_name, :first_name)
                  code << "(LAST_NAME.to_s+' '+FIRST_NAME.to_s).strip.upper_ascii"
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
                  code << "LINE_2.to_s.upper_ascii"
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
                  code << "LINE_3.to_s.upper_ascii"
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
                  code << "LINE_4.to_s.upper_ascii"
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
                  code << "LINE_5.to_s.upper_ascii"
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
                  code << "POST_CODE_AND_CITY.to_s.split(' ')[0].upper_ascii"
                elsif headers.contains?(:post_code)
                  code << "POST_CODE.to_s.strip.upper_ascii"
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
                  code << "POST_CODE_AND_CITY.to_s.split(' ')[1..-1].join(' ').upper_ascii"
                elsif headers.contains?(:city)
                  code << "CITY.to_s.strip.upper_ascii"
                else
                  code << "''"
                end
                code
              end
            }
           ].freeze






  def index
    params[:export_file] ||= "AA.ASC"
    if request.post?
      if params[:files]
        data = generate_data(params[:files].values, :mode => :export)
        send_data(data, :type=>:text, :filename=>(params[:export_file]||'export.csv'))
      else
        
      end
    end

  end

  @@uploads = "A" unless defined? @@uploads
  hide_action :new_upload
  def new_file()
    key = @@uploads.dup
    @@uploads.succ!
    return {:key => key, :label => "Fichier #{key}", :uploaded => false}
  end

  def add_file
    params[:line_size] = 32 if params[:line_size].to_i <= 0
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
      file[:messages] = generate_data(file, :mode=>:test)
    elsif request.delete?
      
    else
      #
      file = new_file
    end
    render :partial => "cleaner/file", :object => file
  end





  protected


  def check_columns(columns)
    messages = []
    doubles = []
    scolumns = columns.compact.sort # {|a,b| a.to_s <=> b.to_s}
    scolumns.each_with_index{|x,i| doubles << x if x == scolumns[i+1]}
    unless doubles.empty?
      doubles = doubles.uniq.collect{|h| '<em>'+COLUMNS[h][0]+'</em>'}
      messages << "ERREUR : Des colonnes sont définies plusieurs fois (#{doubles.to_sentence})".html_safe
    end
    
    missing_columns = []
    
    # Last name & First name
    if columns.include?(:last_name_and_first_name)
      multicol = COLUMNS[:last_name_and_first_name][0]
      if columns.include?(:last_name)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:last_name][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
      if columns.contains?(:first_name)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:first_name][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
    elsif !columns.contains?(:last_name, :first_name)
      missing_columns << :last_name unless columns.include?(:last_name)
      missing_columns << :first_name unless columns.include?(:first_name)
    end
    
    # Post code & City
    if columns.include?(:post_code_and_city)
      multicol = COLUMNS[:post_code_and_city][0]
      if columns.include?(:post_code)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:post_code][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
      if columns.contains?(:city)
        messages << "ERREUR : La colonne <em>#{COLUMNS[:city][0]}</em> ne sera pas prise en compte car <em>#{multicol}</em> est déjà défini".html_safe
      end
    elsif !columns.contains?(:post_code, :city)
      missing_columns << :post_code unless columns.include?(:post_code)
      missing_columns << :city unless columns.include?(:city)
    end
    
    # Missing columns
    if missing_columns.size > 0
      messages << ("ERREUR : Des colonnes ne sont pas définies : "+missing_columns.collect{|c| '<em>'+COLUMNS[c][0]+'</em>'}.to_sentence).html_safe
    end
    return messages
  end


  def generate_data(specs, options = {})

    data, number = '', 0
    messages = []
    data.force_encoding('US-ASCII')
    code = ""
    mode = options[:mode] || :test

    code << "number = 0\n"
    code << "data = ''\n"
    
    specs = [specs] unless specs.is_a?(Array)
    specs.each_with_index do |spec, spec_index|
      file = find_file(spec[:key])
      file.readline
      headers = []
      for k, v in spec[:columns]
        headers[k.to_i] = (v.match(/__unused__/) ? nil : v.to_sym)
      end

      messages += check_columns(headers)

      return messages unless mode == :export or messages.empty?
      
      line_code = ""

      if mode == :export
        line_code << "data"
        EXPORT.each_with_index do |column, index|
          line_code << " << ';'" if index > 0
          ncode = column[:normalize][headers, params]
          ncode =  '\'"\'+(' + ncode + ').gsub(/\"/, "\'\'")+\'"\'' if column[:quote]
          line_code << " << " + ncode
        end
        line_code << ' << "\r\n"'
        line_code << "\n"
      end
      
      if mode == :test
        line_size = params[:line_size].to_i
        line_size = 38 if line_size.zero?
        for l in [:line_2, :line_3, :line_4, :line_5]
          if headers.include?(l)
            col = export_column(l)
            line_code << "if (x = (#{col[:normalize][headers, params]}).strip).size > #{line_size}\n"
            line_code << "  messages << \"L\#{line_number} : <em>#{col[:label]}</em> est sur plus de #{line_size} car. (\#{x.size} car. pour <em>\#{x}</em>).\".html_safe\n"
            line_code << "end\n"
          end
        end
        col1 = export_column(:title)
        col2 = export_column(:last_name_and_first_name)
        line_code << "if (x = (#{col1[:normalize][headers, params]}+' '+#{col2[:normalize][headers, params]}).strip).size > #{line_size}\n"
        line_code << "  messages << \"L\#{line_number} : <em>#{col1[:label]} #{col2[:label]}</em> est sur plus de #{line_size} car. (\#{x.size} car. pour <em>\#{x}</em>).\".html_safe\n"
        line_code << "end\n"
        
        col1 = export_column(:post_code)
        col2 = export_column(:city)
        line_code << "if (x = (#{col1[:normalize][headers, params]}+' '+#{col2[:normalize][headers, params]}).strip).size > #{line_size}\n"
        line_code << "  messages << \"L\#{line_number} : <em>#{col1[:label]} #{col2[:label]}</em> est sur plus de #{line_size} car. (\#{x.size} car. pour <em>\#{x}</em>).\".html_safe\n"
        line_code << "end\n"
        post_code_size = 5
        line_code << "if (x = (#{col1[:normalize][headers, params]}).strip).size > #{post_code_size}\n"
        line_code << "  messages << \"L\#{line_number} : <em>#{col1[:label]}</em> est sur plus de #{post_code_size} car. (\#{x.size} car. pour <em>\#{x}</em>).\".html_safe\n"
        line_code << "end\n"
      end

      if headers.include?(:quantity)
        line_code = "number += 1\n" + line_code
        line_code = "QUANTITY.to_i.times do |qindex|\n"+line_code.strip.gsub(/^/, ' ')+"\nend\n"
      end

      # Substitution of keys
      for column in COLUMNS.keys
        index = headers.index(column)
        unless index.nil?
          line_code.gsub!(/#{column.to_s.upcase}/, "line_array[#{index}]")
        end
      end

      code << "file = find_file('#{spec[:key]}')\n"
      code << "file.readline\n"
      code << "line_number = 1\n"
      code << "file_number = #{spec_index+1}\n"
      code << "for line_array in file.readlines\n"
      code << "  line_number += 1\n"
      unless headers.include?(:quantity)
        code << "  number += 1\n"
      end
      code << line_code.strip.gsub(/^/, '  ')+"\n"
      code << "end\n"

    end

    # code.split(/\n/).each_with_index{|l,i| puts((i+1).to_s.rjust(4)+": "+l)}

    eval(code)

    if mode == :export
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
