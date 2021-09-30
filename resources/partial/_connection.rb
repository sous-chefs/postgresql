property :user,
         String,
         default: 'postgres'

property :database,
         String,
         name_property: true

property :host,
         String

property :port,
         Integer,
         default: 5432

property :psqlrc,
         [true, false],
         default: true
