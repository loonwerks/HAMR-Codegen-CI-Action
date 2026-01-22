# Resolute analysis docker action

This action conducts Resolute analysis on a the named component.

## Inputs

echo "aadl-dir: $1"
echo "platform: $2"
echo "package-name: $3"

### `aadl-dir`

The path to the directory containing the AADL projects relative to the GITHUB_WORKSPACE.  Default `.`.

### `platform`

The HAMR target platform.  Default `microkit`.

### `package-name`

The name of the AADL to translate.  Meaningful only if the platform is not microkit.

## Outputs

### `result`

The JSON-formatted or CSV-formatted summary of analysis results.

## Example usage

~~~
uses: actions/Resolute-CI-Action@v0.1
with:
  aadl-dir: '.'
  platform: 'microkit'
~~~