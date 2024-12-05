using JSON3

"""
    versions_dict = get_versions_in_the_readme_file()

Look in the badges inside the README.md for the versions of Julia.
Assumes that jill.sh and README.md are using the same versions.
"""
function get_versions_in_the_readme_file()
  versions = Dict()
  for line in readlines(joinpath(@__DIR__, "..", "README.md"))
    for (key, regex) in [
      ("lts", r"----lts-(.*)-3a5fcc"),
      ("latest", r"stable-(.*)-3a5fcc"),
      ("rc", r"^!\[Julia (.*)\].*----rc"),
    ]
      m = match(regex, line)
      if m !== nothing
        versions[key] = m[1]
      end
    end
  end

  versions
end

"""
    versions_list = get_versions_online()

Download the file `https://julialang-s3.julialang.org/bin/versions.json` and parse the versions.
"""
function get_versions_online()
  versions_file = download("https://julialang-s3.julialang.org/bin/versions.json")
  read(versions_file, String) |> JSON3.read |> keys .|> string
end

"""
    new_lts = check_lts_update(lts, versions_list)

Check whether the LTS version x.y.z has a new patch version (i.e., z̄ > z).
Returns the `new_lts`, which can be equal to the old, if there are no changes.
"""
function check_lts_update(lts, versions_list)
  version_up_to_minor = join(split(lts, ".")[1:2], ".")
  matching_versions = filter(startswith(version_up_to_minor), versions_list)
  sort!(matching_versions, by=VersionNumber)[end]
end

"""
    new_latest = get_latest_version(versions_list)

Get the LATEST version (x.y.z).
"""
function get_latest_version(versions_list)
  isstable(version_str) = length(VersionNumber(version_str).prerelease) == 0
  matching_versions = filter(isstable, versions_list)
  sort!(matching_versions, by=VersionNumber)[end]
end

"""
    new_rc = get_rc_version(versions_list)

Gets the Release Candidate (x.y.z-rcN).
This can be smaller that the latest.
"""
function get_rc_version(versions_list)
  function isrc(version_str)
    vn = VersionNumber(version_str)
    if length(vn.prerelease) == 0
      return false
    end
    return startswith(vn.prerelease[1], "rc")
  end
  matching_versions = filter(isrc, versions_list)
  sort!(matching_versions, by=VersionNumber)[end]
end

"""
    update_new_versions(new_versions, current_versions)

Goes through a list of files and update versions, if necessary.
"""
function update_new_versions(new_versions, current_versions)

  for dict in (current_versions, new_versions)
    dict["rc-double-hyphen"] = replace(dict["rc"], "-" => "--")
    dict["latest-up-to-minor"] = join(split(dict["latest"], ".")[1:2], ".")
  end

  for (file, regex, key) in [
    ("README.md", r"!\[Julia (.*)\].*stable", "latest"),
    # ("README.md", r"stable-(.*)-3a5fcc", "latest"), # Already done by the line above
    ("README.md", r"!\[Julia (.*)\].*lts", "lts"),
    # ("README.md", r"----lts-(.*)-3a5fcc", "lts"), # Already done by the line above
    ("README.md", r"!\[Julia (.*)\].*rc", "rc"),
    ("README.md", r"----rc-(.*)-3a5fcc", "rc-double-hyphen"),
    ("README.md", r"Currently (.*)\)", "lts"),
    ("jill.sh", r"^JULIA_LTS=(.*)$", "lts"),
    ("jill.sh", r"^JULIA_LATEST=(.*)$", "latest-up-to-minor"),
    ("ci-test.sh", r"^LTS=(.*)$", "lts"),
  ]
    regex_had_match = false
    filepath = joinpath(@__DIR__, "..", file)
    lines = readlines(filepath)
    open(filepath, "w") do io
      for line in lines
        m = match(regex, line)
        out = if m !== nothing
          regex_had_match = true
          replace(line, current_versions[key] => new_versions[key])
        else
          line
        end
        println(io, out)
      end
    end
    @assert regex_had_match
  end
end

function main()
  current_versions = get_versions_in_the_readme_file()
  versions_list = get_versions_online()
  new_versions = Dict()

  new_versions["lts"] = check_lts_update(current_versions["lts"], versions_list)
  new_versions["latest"] = get_latest_version(versions_list)
  new_versions["rc"] = get_rc_version(versions_list)

  update_new_versions(new_versions, current_versions)
end

main()
