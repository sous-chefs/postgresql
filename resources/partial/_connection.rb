property :user,
         String,
         default: 'postgres'

property :database,
         String

property :host,
         String

property :port,
         Integer,
         default: 5432

property :psqlrc,
         [true, false],
         default: true
