namespace PrepareTemplates;

class Program
{
    static void Main(string[] args)
    {
        var cwd = Directory.GetCurrentDirectory();
        foreach (var folder in Directory.EnumerateDirectories(cwd))
        {
            var templates = new Dictionary<string, string>();
            if (File.Exists(Path.Combine(folder, "feature.template")))
            {
                templates.Add("feature", File.ReadAllText(Path.Combine(folder, "feature.template")));
            }
            if (File.Exists(Path.Combine(folder, "comment.template")))
            {
                templates.Add("comment", File.ReadAllText(Path.Combine(folder, "comment.template")));
            }
            if (File.Exists(Path.Combine(folder, "original post.template")))
            {
                templates.Add("original post", File.ReadAllText(Path.Combine(folder, "original post.template")));
            }
            if (templates.Count != 0)
            {
                using var stringDict = File.CreateText(Path.Combine(cwd, folder[(cwd.Length + 1)..] + ".stringsdict"));
                stringDict.WriteLine("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
                stringDict.WriteLine("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">");
                stringDict.WriteLine("<plist version=\"1.0\">");
                stringDict.WriteLine("<dict>");
                if (templates.ContainsKey("original post"))
                {
                    stringDict.WriteLine("\t<key>original post</key>");
                    stringDict.WriteLine("\t<string>{0}</string>", templates["original post"]);
                }
                if (templates.ContainsKey("comment"))
                {
                    stringDict.WriteLine("\t<key>comment</key>");
                    stringDict.WriteLine("\t<string>{0}</string>", templates["comment"]);
                }
                if (templates.ContainsKey("feature"))
                {
                    stringDict.WriteLine("\t<key>feature</key>");
                    stringDict.WriteLine("\t<string>{0}</string>", templates["feature"]);
                }
                stringDict.WriteLine("</dict>");
                stringDict.WriteLine("</plist>");

                using var xcStrings = File.CreateText(Path.Combine(cwd, "new_" + folder[(cwd.Length + 1)..] + ".xcstrings"));
                var strings = new StringsCatalog(templates);
                var result = Newtonsoft.Json.JsonConvert.SerializeObject(strings, Newtonsoft.Json.Formatting.Indented).Replace("\": \"", "\" : \"").Replace("\": {", "\" : {");
                xcStrings.WriteLine(result);
            }
        }
    }
}

class StringsCatalog
{
    public StringsCatalog(IDictionary<string, string> templates)
    {
        SourceLanguage = "en";
        Strings = new Dictionary<string, StringsEntry>();
        foreach (var key in templates.Keys.Order())
        {
            Strings.Add(key, new StringsEntry(templates[key]));
        }
        Version = "1.0";
    }

    [Newtonsoft.Json.JsonProperty(PropertyName = "sourceLanguage")]
    public string SourceLanguage { get; private set; }

    [Newtonsoft.Json.JsonProperty(PropertyName = "strings")]
    public IDictionary<string, StringsEntry> Strings { get; private set; }

    [Newtonsoft.Json.JsonProperty(PropertyName = "version")]
    public string Version { get; private set; }
}

class StringsEntry
{
    public StringsEntry(string value)
    {
        ExtractionState = "manual";
        Localizations = new Localizations(value);
    }

    [Newtonsoft.Json.JsonProperty(PropertyName = "extractionState")]
    public string ExtractionState { get; private set; }

    [Newtonsoft.Json.JsonProperty(PropertyName = "localizations")]
    public Localizations Localizations { get; private set; }
}

class Localizations
{
    public Localizations(string value)
    {
        En = new LanguageUnit(value);
    }

    [Newtonsoft.Json.JsonProperty(PropertyName = "en")]
    public LanguageUnit En { get; private set; }
}

class LanguageUnit
{
    public LanguageUnit(string value)
    {
        StringUnit = new StringUnit(value);
    }

    [Newtonsoft.Json.JsonProperty(PropertyName = "stringUnit")]
    public StringUnit StringUnit { get; private set; }
}

class StringUnit
{
    public StringUnit(string value)
    {
        State = "translated";
        Value = value;
    }

    [Newtonsoft.Json.JsonProperty(PropertyName = "state")]
    public string State { get; private set; }

    [Newtonsoft.Json.JsonProperty(PropertyName = "value")]
    public string Value { get; private set; }
}