require 'json'

class Parser

  def initialize(filename)
		json     = File.read(filename)
		@objects = JSON.parse(json)
	end

	def changed? (pec,record)
		if (	pec.identifier           != record['identifier']           ||
          pec.title                != record['title']                ||
          pec.description          != record['description']          ||
          pec.date                 != record['date']                 ||
          pec.creatorPersName      != record['creatorPersName']      ||
          pec.format               != record['format']               ||
          pec.type                 != record['type']                 ||
          pec.subjectPersName      != record['subjectPersName']      ||
          pec.subjectCorpName      != record['subjectCorpName']      ||
          pec.subjectMeetingName   != record['subjectMeetingName']   ||
          pec.subjectUniformTitle  != record['subjectUniformTitle']  ||
          pec.subjectGeoName       != record['subjectGeoName']       ||
          pec.subjectTopical       != record['subjectTopical']       ||
          pec.creatorMeetingName   != record['creatorMeetName']      ||
          pec.creatorUniformTitle  != record['creatorUniformTitle']  ||
          pec.creatorCorpName      != record['creatorCorpName']      ||
          pec.project              != record['project']              ||
					pec.hasMedia						 != record['hasMedia']
       )
			 true
		else
      false
    end
	end

	def parseRecords()

    @objects.each do |record|

      project              = ['pec']
			hasMedia						 = ""

			# Determine if we are creating new or updating
			results = Printec.find(:identifier=>record['identifier'])

			if (results.count == 0)
				# Creating New
				pec = Printec.create(identifier: record['identifier'], title: record['title'], description: record['description'], date: record['date'], creatorPersName: record['creatorPersName'], format: record['format'], type: record['type'], subjectPersName: record['subjectPersName'], subjectCorpName: record['subjectCorpName'], subjectMeetingName: record['subjectMeetingName'], subjectUniformTitle: record['subjectUniformTitle'], subjectGeoName: record['subjectGeoName'], subjectTopical: record['subjectTopical'], creatorCorpName: record['creatorCorpName'], creatorMeetingName: record['creatorMeetName'], creatorUniformTitle: record['creatorUniformTitle'], project: project)

			elsif (results.count == 1)
				# Updating

				pec = results[0]

				#check if it changed.
				if (changed?(pec,record)) then

          pec.identifier           = record['identifier']
          pec.title                = record['title']
          pec.description          = record['description']
          pec.date                 = record['date']
          pec.creatorPersName      = record['creatorPersName']
          pec.format               = record['format']
          pec.type                 = record['type']
          pec.subjectPersName      = record['subjectPersName']
          pec.subjectCorpName      = record['subjectCorpName']
          pec.subjectMeetingName   = record['subjectMeetName']
          pec.subjectUniformTitle  = record['subjectUniformTitle']
          pec.subjectGeoName       = record['subjectGeoName']
          pec.subjectTopical       = record['subjectTopical']
          pec.creatorMeetingName   = record['creatorMeetName']
          pec.creatorUniformTitle  = record['creatorUniformTitle']
          pec.creatorCorpName      = record['creatorCorpName']
          pec.project              = project
					pec.hasMedia             = hasMedia

				end # changed? check

			else
				# Problem, We should only ever get a 0 or 1 back. if we get more
				# than one back we have duplicate identifiers in the system. bad.
				abort "Error: Duplicate identifiers #{record['identifier']}"
			end #results count

			if File.exists?(sprintf("#{ARGV[0]}/jpg/%s.pdf",pec.identifier))
				pec.digitalImage.content = File.open(sprintf("#{ARGV[0]}/jpg/%s.pdf",pec.identifier))
				pec.hasMedia             = "Digital Content"
			end # pdf exists

			if File.exists?(sprintf("#{ARGV[0]}/thumbs/%s.jpg",pec.identifier))
				pec.thumbnail.content    = File.open(sprintf("#{ARGV[0]}/thumbs/%s.jpg",pec.identifier))
			end # thumb exists

			pec.save
			pec.to_solr

		end
	end
end

if (ARGV.length != 1) then
  abort "Missing export location."
end

if (!Dir.exists? ARGV[0]) then
  abort "Export directory does not exist."
end

data_file = "#{ARGV[0]}/data/pec-data.json"
if (!File.exists? data_file) then
  abort "Data file is missing."
end

data = Parser.new(data_file)
data.parseRecords()
