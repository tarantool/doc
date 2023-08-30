The diagrams in the SQL reference are generated using [Syntrax](https://github.com/kevinpt/syntrax).

# Install Syntrax

```
pip install syntrax
```

## Troubleshooting installation issues

### pip: command not found

- Ensure that Python is installed
- Try `pip3` instead of `pip` 

### error in syntrax setup command: use_2to3 is invalid.

Run `pip3 install "setuptools<58.0.0"`

### ModuleNotFoundError: No module named 'cairo'|'gi'|'pango'

Search on stackoverflow %)

# Generate a diagram

Generate an SVG with the same file name:

```
syntrax <filename>.spec -o svg
```