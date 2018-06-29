class ReportsController < ApplicationController
# :nocov:
  ORGANISATION_MAP = {
    "GEANT" => "GÉANT",
    "GEANT Association" => "GÉANT",
    "GÉANT Association" => "GÉANT",
    "GÉANT Amsterdam" => "GÉANT",
    "GÉANT Association, Amsterdam" => "GÉANT",
    "GEANT Association, Amsterdam" => "GÉANT",
    "GÉANT Association Amsterdam" => "GÉANT",
    "GEANT Association Amsterdam" => "GÉANT",
    "GÉANT Staff Identity Provider" => "GÉANT",
    "TERENA" => "GÉANT",
    "dante" => "GÉANT",
    "DANTE" => "GÉANT",
    "DANTE Ltd" => "GÉANT",
    "Uninett" => "UNINETT",
    "Uninett AS" => "UNINETT",
    "UNINETT AS" => "UNINETT",
    "UNINETT A/S" => "UNINETT",
    "NIIF Programme / KIFU" => "KIFU",
    "KIFU - NIIF" => "KIFU",
    "SURFnet bv" => "SURFnet",
    "SURF" => "SURFnet",
    "HEAnet IdP" => "HEAnet",
    "HEAnet Limited." => "HEAnet",
    "HEAnet Ltd." => "HEAnet",
    "HEAnet Staff" => "HEAnet",
    "Janet/Jisc" => "Jisc",
    "Janet(UK)" => "Jisc",
    "JANET(UK)" => "Jisc",
    "Janet" => "JANET",
    "RedIRIS" => "RedIRIS/Red.es",
    "Red.es/RedIRIS" => "RedIRIS/Red.es",
    "belnet" => "BELNET",
    "Belnet" => "BELNET",
    "EC" => "European Commission",
    "Arnes" => "ARNES",
    "NORDUnet A/S" => "NORDUnet",
    "ACOnet staff" => "ACOnet",
    "Belnet staff" => "BELNET",
    "CANARIE Inc." => "CANARIE",
    "CESNET,a.l.e" => "CESNET",
    "CESNET, z. s. p. o." => "CESNET",
    "CESNET, a. l. e." => "CESNET",
    "CSC / Funet" => "Funet",
    "DeIC" => "DeiC",
    "TERENA Test" => "GÉANT",
    "Greek Research and Technology Network - GRNET" => "GRNET",
    "Greek Research and Technology Network" => "GRNET",
    "Tohoku University / NII" => "Tohoku University",
    "Poznańskie Centrum Superkomputerowo-Sieciowe" => "PSNC",
    "Poznan Supercomputing and Networking Center" => "PSNC",
    "PSNC / PIONIER" => "PSNC",
    "LITNET / Vilnius University" => "LITNET",
    "EENet / HITSA" => "EENet",
    "CSC/Funet" => "Funet",
    "Funet/CSC" => "Funet",
    "CSC - IT Center for Science Ltd." => "Funet",
    "UNINETT / Feide" => "UNINETT",
    "Sunet" => "SUNET",
    "EENet of HITSA" => "EENet",
    "Funet / CSC" => "Funet",
    "Consortium GARR" => "GARR",
    "GIP RENATER" => "RENATER",
    "RESTENA Foundation" => "RESTENA",
    "RESTENA staff" => "RESTENA",
    "RESTENA Staff" => "RESTENA",
    "DFN e.V." => "DFN",
    "DFN-Verein" => "DFN",
    "DFN / LRZ" => "DFN",
    "European Grid Intiative (EGI)" => "EGI.eu",
    "EPFL - EPF Lausanne, CH" => "EPFL - EPF Lausanne",
    "EENet/HITSA" => "EENet",
    "HITSA" => "EENet",
    "Jisc Technologies" => "Jisc",
    "Jisc (Janet)" => "Jisc",
    "NIIF Institute" => "NIIFI",
    "PSNC - Poznan Supercomputing and Networking Center [via OpenID]" => "PSNC",
    "PSNC - Poznan Supercomputing and Networking Center" => "PSNC",
    "Vilnius University / LITNET" => "LITNET",
    "Litnet" => "LITNET",
    "IUCC-Israel" => "IUCC",
    "SRCE / CARNet" => "CARNet",
    "CARNET" => "CARNet",
    "Srce" => "CARNet",
    "FCT|FCCN" => "FCCN",
    "RENAM- Republic of Moldova" => "RENAM",
    "University of Vienna, ZID (Computer Center)" => "University of Vienna",
    "Vienna University of Technology" => "University of Vienna",
    "RNP - Rede Nacional de Ensino e Pesquisa" => "RNP",
    "RNP (Brazilian NREN)" => "RNP",
    "UBUNTUNET ALLIANCE" => "UbuntuNet Alliance",
    "Umeå university" => "Umeå University",
    "TEIN Cooperation Center(TEIN*CC)" => "TEIN*CC",
    "TEIN cooperation center" => "TEIN*CC",
    "URAN Association IdP" => "URAN"
  }

  def index
  end

  def participation
    if params[:filter_by_taskforce].present?
      @events = Event.tagged_with(params[:filter_by_taskforce]).order(:tstart)
      @participants = Subscription.where(event: @events)
        .where("regoption = 'register' OR regoption = 'remote'").group_by { |s| s[:organisation] }
    end
  end

  def participants_for_nren
    params[:event_tags] ||= 'TF-MSP'
    events = Event.tagged_with(params[:event_tags]).order(:tstart)

    participants = Subscription.where(event: events)
      .where("regoption = 'register' OR regoption = 'remote'")
      .group_by { |s| s[:event_id] }

    h = []

    events.each do |event|
      p = {}
      participants_at_event = participants[event.id]
      if participants_at_event
        participants_at_event.each do |participant|
          organisation = ORGANISATION_MAP[participant[:organisation]] || participant[:organisation]
          p[:_event] = { id: event.id, name: event.name, tags: event.tags.map(&:name), date: event.tstart.strftime("%b %Y") }
          p[organisation] ||= []
          p[organisation] << participant
        end
        h << p
      end
    end

    render json:
    {
      key: "Participants per event",
      events: h,
      organisations: flatten_organisations(Subscription.where(event: events)
            .where("regoption = 'register' OR regoption = 'remote'")
            .group(:organisation)
            .pluck(:organisation)).map { |org| { name: org } }
    }

  end

  def taskforces
  end

  def totalparticipation
  end

  def participation_by_taskforces
    # August 2015 - August 2016: 462
    # August 2016 - August 2017: 389
    # May 2016 - September 2017: 466
    participants = []
    date_range = [
      ["August 2015", "August 2016"],
      ["August 2016", "August 2017"],
      ["May 2016", "August 2017"]
    ].map do |r|
      r.map { |c| Time.zone.parse(c) }
    end
    date_range.push([(Time.zone.now - 2.years), Time.zone.now])

    #params[:date_range] ||= 3
    %w(SIG-NGN SIG-SCOPE SIG-Greenhouse SIG-Multimedia SIG-Marcomms SIG-MSP SIG-ISM SIG-NOC SIG-PMV SIG-CISS TF-WebRTC TF-MNM TF-NOC TF-Storage TF-Media TF-MSP TF-RED TF-CPR).each do |taskforce|

      Subscription.includes(:event).includes(:user)
        .where(event: Event.tagged_with(taskforce).where(
          tstart: date_range[2][0]..date_range[2][1]
        ))
        .where("regoption = 'register' OR regoption = 'remote'").each do |s|
          participants << {
            taskforce_id: taskforce,
            event_name: s.event.name,
            date: s.event.tstart.strftime("%Y-%m"),
            name: s.name,
            id: s.user.try(:id),
            org: ReportsController::ORGANISATION_MAP[s.organisation.strip] ||= s.organisation.strip
          }
        end

    end

    render json:
    {
      participants: participants
    }
  end

  def heatmap
  end

  def participation_by_country
    participants = {
      2011 => {
        'Zambia' => 2,
        'Turkey' => 2,
        'Palestine' => 2,
        'New Zealand' => 2,
        'Luxembourg' => 2,
        'Kyrgyzstan' => 2,
        'Cyprus' => 2,
        'Chile' => 2,
        'Grenada' => 2,
        'Colombia' => 2,
        'Afghanistan' => 2,
        'Jordan' => 3,
        'Hungary' => 3,
        'Uruguay' => 3,
        'Israel' => 3,
        'Armenia' => 4,
        'Albania' => 4,
        'Ireland' => 4,
        'Romania' => 4,
        'Austria' => 5,
        'South Africa' => 5,
        'Korea' => 5,
        'Australia' => 5,
        'Japan' => 6,
        'Latvia' => 6,
        'Estonia' => 7,
        'Greece' => 7,
        'Canada' => 7,
        'Brazil' => 7,
        'China' => 7,
        'Lithuania' => 7,
        'Croatia'=> 7,
        'Iceland' => 8,
        'Sweden' => 8,
        'Slovenia' => 9,
        'Belgium' => 9,
        'Slovakia'=> 9,
        'Portugal'=> 11,
        'Norway' => 13,
        'Finland' => 15,
        'Italy' => 16,
        'Poland' => 17,
        'Spain' => 17,
        'Denmark' => 20,
        'Switzerland'=> 23,
        'United States'=>24,
        'France' => 24,
        'Germany' => 25,
        'United Kingdom'=>45,
        'Czech Rep.'=>48,
        'Netherlands'=> 71
      },
      2012 => {
        'Albania' => 2,
        'Turkey' => 2,
        'Tanzania' => 2,
        'Azerbaijan' => 2,
        'Qatar' => 2,
        'Peru' => 2,
        'Luxembourg' => 2,
        'Grenada' => 2,
        'Kenya' => 2,
        'Afghanistan' => 2,
        'Korea' => 3,
        'Cyprus' => 3,
        'New Zealand' => 3,
        'Israel' => 3,
        'Uruguay' => 3,
        'Malawi' => 4,
        'Latvia' => 4,
        'Slovakia' => 4,
        'Austria' => 4,
        'Ireland' => 5,
        'Romania' => 5,
        'Hungary' => 6,
        'Croatia' => 7,
        'Portugal' => 7,
        'Lithuania' => 8,
        'South Africa' => 8,
        'Estonia' => 8,
        'Greece' => 9,
        'Belgium' => 9,
        'Australia' => 9,
        'Sweden' => 9,
        'France' => 10,
        'Norway' => 10,
        'Canada' => 11,
        'Japan' => 11,
        'Slovenia' => 11,
        'Brazil' => 12,
        'Iceland' => 13,
        'Italy' => 13,
        'Finland' => 15,
        'Spain' => 16,
        'Switzerland' => 20,
        'Poland' => 20,
        'Czech Rep.' => 21,
        'Denmark' => 21,
        'Germany' => 28,
        'United States' => 30,
        'United Kingdom' => 55,
        'Netherlands' => 87
      },
      2013 => {
        'Zambia' => 2,
        'Uzbekistan' => 2,
        'United Arab Emirates' => 2,
        'Uganda' => 2,
        'Singapore' => 2,
        'Malawi' => 2,
        'Luxembourg' => 2,
        'Latvia' => 2,
        'El Salvador' => 2,
        'Georgia' => 2,
        'Jordan' => 2,
        'Armenia' => 3,
        'Turkey' => 3,
        'Grenada' => 3,
        'Estonia' => 3,
        'Chile' => 3,
        'Kyrgyzstan' => 3,
        'Azerbaijan' => 3,
        'China' => 3,
        'Kenya' => 4,
        'Croatia' => 4,
        'New Zealand' => 4,
        'Slovakia' => 4,
        'Iceland' => 4,
        'Israel' => 5,
        'Afghanistan' => 5,
        'Uruguay' => 5,
        'Austria' => 5,
        'Colombia' => 5,
        'Portugal' => 6,
        'France' => 6,
        'Korea' => 7,
        'Slovenia' => 7,
        'Canada' => 7,
        'Greece' => 8,
        'Lithuania' => 8,
        'Australia' => 9,
        'South Africa' => 10,
        'Finland' => 11,
        'Hungary' => 11,
        'Belgium' => 12,
        'Sweden' => 12,
        'Spain' => 12,
        'Norway' => 13,
        'Italy' => 13,
        'Ireland' => 14,
        'Brazil' => 16,
        'Czech Rep.' => 18,
        'Japan' => 18,
        'Poland' => 22,
        'Switzerland' => 27,
        'Denmark' => 28,
        'Germany' => 34,
        'United States' => 34,
        'United Kingdom' => 57,
        'Netherlands' => 150
      },
      2014 => {
        'United Arab Emirates' => 2,
        'Austria' => 2,
        'Trinidad and Tobago' => 2,
        'Taiwan' => 2,
        'Malta' => 2,
        'Ecuador' => 2,
        'Jordan' => 2,
        'Grenada' => 2,
        'Korea' => 2,
        'Mozambique' => 3,
        'Zambia' => 3,
        'Estonia' => 3,
        'Chile' => 3,
        'Turkey' => 3,
        'Luxembourg' => 3,
        'Ghana' => 3,
        'Israel' => 3,
        'Qatar' => 3,
        'New Zealand' => 3,
        'Romania' => 3,
        'Malawi' => 4,
        'Kenya' => 4,
        'Singapore' => 4,
        'Uruguay' => 4,
        'Afghanistan' => 4,
        'Iceland' => 5,
        'Greece' => 6,
        'South Africa' => 7,
        'Portugal' => 7,
        'China' => 8,
        'France' => 8,
        'Lithuania' => 8,
        'Croatia' => 8,
        'Hungary' => 8,
        'Slovenia' => 10,
        'Finland' => 11,
        'Canada' => 12,
        'Australia' => 13,
        'Belgium' => 14,
        'Czech Rep.' => 14,
        'Italy' => 15,
        'Japan' => 15,
        'Norway' => 15,
        'Brazil' => 16,
        'Spain' => 16,
        'Poland' => 17,
        'Sweden' => 20,
        'Switzerland' => 28,
        'Germany' => 36,
        'Ireland' => 43,
        'United States' => 43,
        'United Kingdom' => 44,
        'Denmark' => 44,
        'Netherlands' => 61
      },
      2015 => {
        'Zambia' =>2,
        'Uruguay' =>1,
        'United States' =>63,
        'United Kingdom' =>60,
        'United Arab Emirates' =>2,
        'Uganda' =>1,
        'Turkey' =>1,
        'Switzerland' =>15,
        'Sweden' =>16,
        'Spain' =>13,
        'South Africa' =>11,
        'Slovenia' =>12,
        'Singapore' =>6,
        'Romania' =>2,
        'Portugal' =>41,
        'Poland' =>23,
        'Norway' =>9,
        'New Zealand' =>6,
        'Netherlands' =>69,
        'Mozambique' =>1,
        'Morocco' =>1,
        'Mexico' =>1,
        'Malta' =>1,
        'Malawi' =>2,
        'Luxembourg' =>5,
        'Lithuania' =>9,
        'Kyrgyzstan' =>2,
        'Korea' =>5,
        'Kenya' =>2,
        'Jordan' =>1,
        'Japan' =>17,
        'Italy' =>13,
        'Israel' =>3,
        'Ireland' =>11,
        'Iceland' =>5,
        'Hungary' =>10,
        'Greece' =>6,
        'Ghana' =>1,
        'Germany' =>31,
        'France' =>14,
        'Finland' =>15,
        'Estonia' =>4,
        'Ecuador' =>5,
        'Dominican Rep.' =>1,
        'Denmark' =>29,
        'Czech Rep.' =>14,
        'Croatia' =>4,
        'Colombia' =>2,
        'China' =>9,
        'Chile' =>3,
        'Canada' =>7,
        'Cambodia' =>1,
        'Bulgaria' =>2,
        'Brazil' =>8,
        'Belgium' =>17,
        'Azerbaijan' =>1,
        'Austria' =>6,
        'Australia' =>11,
        'Albania' =>3
      },
      2016 =>
        {"Armenia"=>1, "Austria"=>6, "Australia"=>9, "Azerbaijan"=>2, "Bosnia and Herz."=>1, "Belgium"=>13, "Brazil"=>3,
          "Belarus"=>1, "Canada"=>16, "Switzerland"=>18, "Chile"=>1, "China"=>8, "Colombia"=>1, "Cyprus"=>1, "Czech Rep."=>46,
          "Germany"=>30, "Denmark"=>23, "Ecuador"=>3, "Estonia"=>6, "Spain"=>13, "Finland"=>8, "France"=>14, "United Kingdom"=>57,
          "Georgia"=>2, "Ghana"=>5, "Greece"=>7, "Croatia"=>4, "Hungary"=>6, "Ireland"=>12, "Israel"=>8, "Iran"=>2, "Iceland"=>2,
          "Italy"=>18, "Jordan"=>1, "Japan"=>14, "Kenya"=>2, "Korea"=>3, "Lebanon"=>1, "Lithuania"=>11, "Luxembourg"=>2, "Moldova"=>1,
          "Macedonia"=>1, "Malawi"=>2, "Mozambique"=>2, "Nigeria"=>1, "Netherlands"=>73, "Norway"=>19, "Nepal"=>1, "New Zealand"=>3,
          "Poland"=>28, "Portugal"=>6, "Romania"=>2, "Serbia"=>2, "Russia"=>4, "Sweden"=>12, "Singapore"=>2, "Slovenia"=>7,
          "Senegal"=>1, "Tunisia"=>1, "Taiwan"=>1, "United States"=>61, "Uruguay"=>1, "South Africa"=>10}
    }

    render json: participants
  end

  def topics
  end

  def presentations_by_topic
    presentations = []

    Presentation.includes(:subscription).each do |p|
      presentations << {
        title: p.title.gsub(/\"/, '\'').strip,
        author: p.subscription.name.downcase,
        date: p.subscription.event.tstart.to_date,
        organisation: flatten_organisation(p.subscription.organisation),
        topic: p.topics.pluck(:name).first
      }
    end

    render json: presentations
  end

private

  def flatten_organisations(organisations)
    organisations.map(&:strip).map { |org| ORGANISATION_MAP[org] || org }.uniq
  end

  def flatten_organisation(organisation)
    ORGANISATION_MAP[organisation.strip] ||= organisation.strip
  end


end

  # :nocov: