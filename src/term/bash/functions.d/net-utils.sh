qdig() {
  dig $@ | grep -v '^\s*\(;\|$\)'
}

export -f qdig
