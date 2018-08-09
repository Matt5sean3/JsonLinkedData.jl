
# A JSON-LD processing implementation

# JSON-LD seems pretty weird at first glance

# Needs a good understanding of IRI's too

# The main idea for JSON-LD is that IRI's used in keys can instead be mapped to keyword values using contexts to allow easier processing
# JSON-LD also allows type metadata to be specified with the @type property that can be applied to context keyword definitions and to document nodes

# Relative IRIs get interesting as they are dependent on the document from which they were fetched

# application/ld+json is the mime-type

# Needs an implementation for transforming from IRIs to URIs and so-forth
struct IRI
  identifier::String
end

# TODO perform transformation from IRI to URI
as_uri(id::IRI) = id.identifier

# If the IRI references a valid JSON-LD context spec then types can be generated from the spec easily enough
macro LdContextType(iri::String)
  # Tries to get the spec remotely from the provided IRI
end

macro LdType(iri::String, properties::Expr...)
  # Define an LdType using ordinary type syntax
  if properties.head != :type
    throw("LdTypes must be declared with the same syntax as Julia types")
  end
  # LdType properties are wrapped to be Nullable while processed to a regular type
end

# Need to implement three primary algorithms

function dereference_uri(uri)
  # TODO Having this be a blocking operation is likely to be an issue
  r = HTTP.request("GET", uri, [("Accept", "application/ld+json")])
  return JSON.parse(String(r.body))
end

# === CONTEXT PROCESSING ALGORITHM ===

# Based off of the default implementation
# TODO Something that does processing based on native Julia structs would be nicer
# Probably would be much more efficient and readable too

# Some sub-algorithms too, kind of sucks for type stability
# remote_contexts is there to avoid cyclicality problems
function add_local_context(active_context::Dict{String, Any}, local_context, remote_contexts::Set{String} = Set{String}())
  # Wrap the local context as an array
  return add_local_context(active_context, Any[local_context], remote_contexts)
end

function add_local_context(active_context::Dict{String, Any}, local_context::Array{Any, 1}, remote_contexts::Set{String} = Set{String}())
  # Making it a copy is probably good to keep logic clean
  # May be strictly unnecessary unless multi-threading is brought in
  result = copy(active_context)
  for added_context in local_context
    result = add_single_local_context(result, added_context, remote_contexts)
  end
end

# Local contexts must be strings, Dicts, or nothing
function add_single_local_context(active_context::Dict{String, Any}, local_context, remote_contexts::Set{String} = Set{String}())
  throw("Invalid local context: An invalid local context was detected")
end

function add_single_local_context(active_context::Dict{String, Any}, local_context::String, remote_contexts::Set{String} = Set{String}())
  uri = iri_to_uri(local_context)
  if uri in remote_contexts
    throw("Recursive context inclusion error")
  end
  # Required to be a dictionary
  context = dereference_uri(iri)
  if !(isa(context, Dict) && ("@context" in keys(context)))
    throw("Invalid remote context")
  end

  # TODO Hmm, I'm pretty sure I recurse using the value from @context, even though their algorithm is a little shady on that point
  return add_local_context(active_context, context["@context"], Set([remote_contexts..., uri]))
end

function add_single_local_context(active_context::Dict{String, Any}, local_context::Dict{String, Any}, remote_contexts::Set{String} = Set{String}())
  result = copy(active_context)
  # Check for an @base key
  if "@base" in keys(local_context)
    value = local_context["@base"]
  end
  if "@version" in keys(local_context) && local_context["@version"] != 1.1
    throw("Invalid @version value: The @version key was used in a context with an out of range value")
    # TODO handle processing mode behavior
  end
  if "@vocab" in keys(local_context)
  end
  # Process languages
  if "@language" in keys(local_context)
    value = local_context["@language"]
    if value == nothing
      delete!(result, "@language")
    elseif isa(value, String)
      local_context["@language"] = lowercase(value)
    else
      throw("Invalid default language")
    end
  end
  return result
end

# TODO is the copy operation really necessary? Seems like it should be a nop.
add_single_local_context(active_context::Dict{String, Any}, local_context::Void, remote_contexts::Set{String} = Set{String}()) = copy(active_context)

function iri_to_uri(iri)
  # TODO actually resolve the iri to a uri per RFC3987, ugh
  return iri
end



