class PlacenamesService
  
  API_KEY = ENV['OPENNAMES_API_KEY']
  
  def initialize(query)
    @query = query
  end
  
  def search
    json = JSON.parse open(url).read
    results = filter(json['results'])
    results.map { |r| r.values }.flatten
  end
  
  private
  
    def url
      "#{base_name}?query=#{@query}&fq=#{URI.encode types}&bounds=#{bounds}&key=#{API_KEY}"
    end
    
    def base_name
      'https://api.ordnancesurvey.co.uk/opennames/v1/find'
    end
    
    def types
      ['Town','City','Village','Hamlet'].map { |t|
        "LOCAL_TYPE:#{t}"
      }.join(' ')
    end
    
    def bounds
      '537525,180625,625918,248940'
    end
    
    def filter(results)
      return [] if results.nil?
      results.select do |r|
        r['GAZETTEER_ENTRY']['NAME1'] =~ /\A#{@query}/i
      end
    end
  
end
