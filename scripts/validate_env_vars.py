#!/usr/bin/env python3
"""
Check that every environment variable referenced in docker-compose.yml
(e.g. ${VAR} or ${VAR:-default}) has an entry in .env.example.
"""
import re
import sys


def main():
    with open("docker-compose.yml") as f:
        compose = f.read()
    with open(".env.example") as f:
        env_example = f.read()

    compose_vars = set(re.findall(r"\$\{([A-Z_][A-Z0-9_]*)", compose))
    example_vars = set(re.findall(r"^([A-Z_][A-Z0-9_]*)=", env_example, re.MULTILINE))

    missing = compose_vars - example_vars
    if missing:
        print("  ❌  Variables used in docker-compose.yml but missing from .env.example:")
        for v in sorted(missing):
            print(f"       {v}")
        sys.exit(1)

    print("  ✅  All compose variables are documented in .env.example")


if __name__ == "__main__":
    main()
