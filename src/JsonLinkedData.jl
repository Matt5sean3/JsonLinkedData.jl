module JsonLinkedData

function ActiveContext(json::Dict{String, Any}, base_iri::String)
  ActiveContext(json, base_iri)
end

# Need some types for algorithm implementation
struct TermDefinition
  iri_mapping::Dict{String, Any}
  reverse_property::Bool
  type_mapping::Nullable{} # What sort of type?
  language_mapping::Nullable{} # What sort of type?
  context::Nullable{} # What is this for? What type?
  prefix_flag::Bool # What is this for?
  container_mapping::Dict{String, Any} # What is this for?
end

# Lots of type enforcement stuff can be handled implicitly
struct ActiveContext
  term_definitions::Dict{String, TermDefinition}
  base_iri::String
  vocabulary_mapping::Dict{String, Any}
  default_language::String
end

jsonld_keywords = Set{String}([
  ":",
  "@base",
  "@container",
  "@context",
  "@graph",
  "@id",
  "@index",
  "@language",
  "@list",
  "@nest",
  "@none",
  "@prefix",
  "@reverse",
  "@set",
  "@type",
  "@value",
  "@version",
  "@vocab"
])

# package code goes here
include("iri_expansion.jl")
include("create_term_definition.jl")
include("context_processing.jl")

end # module
