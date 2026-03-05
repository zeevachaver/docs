import tomllib
from pathlib import Path
import tomlkit
from tomlkit.items import Array

REPOS_FILE = "repos.txt"

def prefix_nav(item, repo_name):
    """
    Recursively adds the repo prefix to paths and ensures
    everything is a clean Python primitive (str, list, dict).
    """
    if isinstance(item, str):
        # Don't prefix external links or already prefixed paths
        if item.startswith(("http", f"{repo_name}/")):
            return str(item)
        # Handle empty strings or root index cases
        if not item or not repo_name:
            return str(item)
        return f"{repo_name}/{item}"

    if isinstance(item, list):
        return [prefix_nav(i, repo_name) for i in item]

    if isinstance(item, dict):
        return {str(k): prefix_nav(v, repo_name) for k, v in item.items()}

    return item

def main():
    # 1. Load the base configuration
    base_path = Path("zensical.base.toml")
    if not base_path.exists():
        print(f"❌ Error: {base_path} not found.")
        return

    with open(base_path, "rb") as f:
        base_data = tomllib.load(f)

    # Extract project settings (site_name, etc.)
    project_config = base_data.get("project", {})
    # Start the final nav list with any items already in base
    final_nav = prefix_nav(project_config.get("nav", []), "")

    # 2. Merge repo-specific navigation files
    if Path(REPOS_FILE).exists():
        with open(REPOS_FILE, "r", encoding="utf-8") as f:
            repos = [line.strip() for line in f if line.strip()]

        for repo in repos:
            nav_path = Path("docs") / repo / "nav.toml"
            if nav_path.exists():
                print(f"Merging: {nav_path}")
                with open(nav_path, "rb") as nf:
                    data = tomllib.load(nf)
                    # Support both 'nav = [...]' and top-level lists
                    fragment = data.get("nav", data)

                if isinstance(fragment, list):
                    final_nav.extend(prefix_nav(fragment, repo))
                else:
                    # If it's a single dict (a section), wrap it in a list
                    final_nav.append(prefix_nav(fragment, repo))
            else:
                print(f"⚠️ Warning: {nav_path} missing.")
    else:
        print(f"{REPOS_FILE} not found; skipping merge.")

    # 3. Build the TOML Document
    doc = tomlkit.document()
    project = tomlkit.table()

    # Add project metadata (site_name, theme, etc.) excluding the old nav
    for k, v in project_config.items():
        if k != "nav":
            project.add(k, v)

    # --- FORCING THE SINGLE ARRAY FORMAT ---
    # This prevents tomlkit from generating several [[project.nav]] blocks
    nav_array = tomlkit.array()
    nav_array.multiline(True) # Makes it more human-readable

    for item in final_nav:
        if isinstance(item, dict):
            # Inline tables prevent Zensical from seeing "Unknown nav item: dict"
            it = tomlkit.inline_table()
            it.update(item)
            nav_array.append(it)
        else:
            nav_array.append(item)

    project.add("nav", nav_array)
    doc.add("project", project)

    # Append any other top-level tables (e.g., [build], [theme]) from base
    for k, v in base_data.items():
        if k != "project":
            doc.add(k, v)

    output_file = "zensical.generated.toml"
    with open(output_file, "w", encoding="utf-8") as f:
        f.write(doc.as_string())

if __name__ == "__main__":
    main()