# Contributing to SmartIce Plugin Marketplace

We welcome plugin contributions! Follow these steps to submit your plugin.

## Submission Process

1. **Fork this repository**

2. **Add your plugin** to the `plugins/` directory:
   ```
   plugins/
   └── your-plugin-name/
       ├── .claude-plugin/
       │   └── plugin.json
       ├── skills/           # optional
       ├── commands/         # optional
       ├── agents/           # optional
       └── README.md
   ```

3. **Update marketplace.json** - Add your plugin entry to `.claude-plugin/marketplace.json`:
   ```json
   {
     "name": "your-plugin-name",
     "source": "./plugins/your-plugin-name",
     "description": "Brief description of what your plugin does",
     "version": "1.0.0",
     "category": "category-name",
     "keywords": ["keyword1", "keyword2"]
   }
   ```

4. **Submit a Pull Request** with:
   - Clear description of what your plugin does
   - Any dependencies or requirements (API keys, etc.)
   - Screenshots or examples if applicable

## Plugin Requirements

- **Unique name**: Use kebab-case (e.g., `my-awesome-plugin`)
- **Valid plugin.json**: Must include name, version, description, author
- **Documentation**: Include a README.md explaining usage
- **No secrets**: Never commit API keys or credentials
- **Tested**: Verify your plugin works before submitting

## Plugin Structure

```
your-plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Required: plugin manifest
├── README.md                 # Required: documentation
├── skills/                   # Optional: agent skills
│   └── skill-name/
│       └── SKILL.md
├── commands/                 # Optional: slash commands
│   └── command-name.md
├── agents/                   # Optional: custom agents
│   └── agent-name.md
├── hooks/                    # Optional: event hooks
│   └── hooks.json
└── scripts/                  # Optional: utility scripts
```

## Categories

Use one of these categories in your marketplace entry:
- `design` - UI/UX and frontend design tools
- `development` - Development workflow tools
- `testing` - Testing and QA tools
- `documentation` - Documentation generators
- `integration` - External service integrations
- `productivity` - General productivity tools

## Questions?

Open an issue if you have questions about contributing.
