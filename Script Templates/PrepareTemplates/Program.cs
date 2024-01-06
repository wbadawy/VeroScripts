namespace PrepareTemplates;

class Program
{
    static void Main()
    {
        var cwd = Directory.GetCurrentDirectory();
        var templateCatalog = new HubsCatalogg();
        foreach (var folder in Directory.EnumerateDirectories(cwd).Order())
        {
            var templates = new Dictionary<string, string>();
            Console.WriteLine("Searching {0} folder...", folder);
            foreach (var file in Directory.EnumerateFiles(folder, "*.template").Order())
            {
                var fileName = Path.GetFileNameWithoutExtension(file);
                Console.WriteLine("\tAdding {0}...", file);
                templates.Add(fileName, File.ReadAllText(file));
            }
            if (templates.Count != 0)
            {
                var hubName = folder[(cwd.Length + 1)..];
                templateCatalog.Hubs.Add(new Hub(hubName, templates));
            }
        }
        using var catalogFile = File.CreateText(Path.Combine(cwd, "hubs.json"));
        var catalogJson = Newtonsoft.Json.JsonConvert.SerializeObject(templateCatalog, Newtonsoft.Json.Formatting.Indented);
        catalogFile.WriteLine(catalogJson);
    }
}

class HubsCatalogg
{
    public HubsCatalogg()
    {
        Hubs = new List<Hub>();
    }

    [Newtonsoft.Json.JsonProperty(propertyName: "hubs")]
    public IList<Hub> Hubs { get; private set; }
}

class Hub
{
    public Hub(string name, IDictionary<string, string> templates)
    {
        Name = name;
        Templates = templates.Keys.Select(template => new Template(template, templates[template])).ToList();
    }

    [Newtonsoft.Json.JsonProperty(propertyName: "name")]
    public string Name { get; }

    [Newtonsoft.Json.JsonProperty(propertyName: "templates")]
    public List<Template> Templates { get; }
}

class Template
{
    public Template(string name, string script)
    {
        Name = name;
        Script = script;
    }

    [Newtonsoft.Json.JsonProperty(propertyName: "name")]
    public string Name { get; }

    [Newtonsoft.Json.JsonProperty(propertyName: "template")]
    public string Script { get; }
}
