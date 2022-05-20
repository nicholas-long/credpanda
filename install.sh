#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cat << EOF > /usr/local/bin/credpanda
#!/bin/sh
$(pwd)/credpanda \$@
EOF
chmod +x /usr/local/bin/credpanda
