
# Hmm, mutates active_context
function create_term_definition(
    active_context::Dict{String, Any},
    local_context::Dict{String, Any},
    term::String,
    defined::Dict{String, Bool} = Dict{String, Bool}())
  # 4.2.2 -> 1
  if term in keys(defined)
    if defined[term]
      # Already defined, don't define again
      return nothing
    else
      # In the process of being defined
      throw("Cyclic IRI mapping")
    end
  end
  # 4.2.2 -> 2
  # Set the term as in the process of being defined
  defined[term] = false
  # 4.2.2 -> 3
  # Throw an exception if redefining a a keyword
  if term in jsonld_keywords
    throw("keyword redefinition error")
  end
  # 4.2.2 -> 4
  # Remove any existing term definition in active_context
  delete!(active_context, term)

  # 4.2.2 -> 5
  # Initialize value to a copy of term from the local_context
  value = copy(local_context[term])

  # 4.2.2 -> 6
  # If value is null or it's @id is null, set the term as null, then return
  if value == nothing || (isa(value, Dict) && value["@id"] == nothing)
    active_context[term] = nothing
    defined[term] = true
    return;
  end

  # 4.2.2 -> 7
  # Normalize value to a Dict
  simple_term = isa(value, String)
  if simple_term
    value = Dict{String, String}("@id" => value)
  end

  # 4.2.2 -> 8
  # Throw an error if value isn't a Dict by now
  if !isa(value, Dict)
    throw("Invalid term definition")
  end

  # 4.2.2 -> 9
  # Create a new term definition, definition
  definition = TermDefinition()

  # 4.2.2 -> 10
  if "@type" in keys(value)
    # 4.2.2 -> 10.1
    # Initialize type to @type
    ttype = value["@type"]
    isa(value["@type"], String) || throw("Invalid type mapping error")

    # 4.2.2 -> 10.2
    # TODO Use IRI expansion

    definition["@type"] = ttype
  end

  # 4.2.2 -> 11
  if "@reverse" in keys(value)
    # 4.2.2 -> 11.1
    ("@id" in keys(value) || "@nest" in keys(value)) && throw("Invalid reverse property")
    isa(value["@reverse"], String) || throw("Invalid IRI mapping")
    # TODO set IRI mapping of definition, not sure what the IRI mapping was
    definition[]
  end


end

