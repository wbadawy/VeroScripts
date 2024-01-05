//
//  ContentView.swift
//  Vero Scripts
//
//  Created by Andrew Forget on 2024-01-03.
//

import SwiftUI

enum MembershipCase: String, CaseIterable, Identifiable {
    case none = "None",
         artist = "Artist",
         member = "Member",
         vipMember = "VIP Member",
         goldMember = "VIP Gold Member",
         platinumMember = "Platinum Member",
         eliteMember = "Elite Member",
         hallOfFameMember = "Hall of Fame Member",
         diamondMember = "Diamond Member"
    var id: Self { self }
}

enum NewMembershipCase: String, CaseIterable, Identifiable {
    case none = "None",
         member = "Member",
         vipMember = "VIP Member"
    var id: Self { self }
}

enum StaffLevelCase: String, CaseIterable, Identifiable {
    case mod = "Mod",
         admin = "Admin"
    var id: Self { self }
}

enum PageCase: String, CaseIterable, Identifiable {
    case custom = "custom",
         allTrees = "alltrees",
         beaches = "beaches",
         birds = "birds",
         books = "books",
         canada = "canada",
         foggy = "foggy",
         landscape = "landscape",
         longExposure = "longexposure",
         nightShots = "nightshots",
         people = "people",
         potd = "potd",
         reflection = "reflection",
         skies = "skies",
         usa = "usa"
    var id: Self { self }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

func matches(of regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

struct ContentView: View {
    @State var Membership: MembershipCase = MembershipCase.none
    @State var UserName: String = ""
    @State var YourName: String = UserDefaults.standard.string(forKey: "YourName") ?? ""
    @State var Page: PageCase = PageCase(rawValue: UserDefaults.standard.string(forKey: "Page") ?? PageCase.custom.rawValue) ?? PageCase.custom
    @State var PageName: String = UserDefaults.standard.string(forKey: "PageName") ?? ""
    @State var PageStaffLevel: StaffLevelCase = StaffLevelCase(rawValue: UserDefaults.standard.string(forKey: "StaffLevel") ?? StaffLevelCase.mod.rawValue) ?? StaffLevelCase.mod
    @State var FirstForPage: Bool = false
    @State var FeatureScript: String = ""
    @State var CommentScript: String = ""
    @State var OriginalPostScript: String = ""
    @State var NewMembership: NewMembershipCase = NewMembershipCase.none
    @State var NewMembershipScript: String = ""
    @State var ShowingAlert = false
    @State var AlertTitle: String = ""
    @State var AlertMessage: String = ""

    var body: some View {
        VStack {
            Group {
                // User name editor
                HStack {
                    Text("User: ")
                        .frame(width: 40, alignment: .leading)
                    TextField(
                        "Enter user name:",
                        text: $UserName.onChange(userNameChanged)
                    )
                }

                // User level picker
                Picker("Level: ", selection: $Membership.onChange(membershipChanged)) {
                    ForEach(MembershipCase.allCases) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                .focusable()

                // Your name editor
                HStack {
                    Text("You: ")
                        .frame(width: 40, alignment: .leading)
                    TextField(
                        "Enter your name:",
                        text: $YourName.onChange(yourNameChanged)
                    )
                }

                // Page name editor
                HStack {
                    Picker("Page: ", selection: $Page.onChange(pageChanged)) {
                        ForEach(PageCase.allCases) { pageCase in
                            Text(pageCase.rawValue).tag(pageCase)
                        }
                    }
                    .focusable()
                    TextField(
                        "Enter page name:",
                        text: $PageName.onChange(pageNameChanged)
                    )
                    .disabled(Page != PageCase.custom)
                    .focusable(Page == PageCase.custom)
                    Picker("Page staff level: ", selection: $PageStaffLevel.onChange(pageStaffLevelChanged)) {
                        ForEach(StaffLevelCase.allCases) { staffLevelCase in
                            Text(staffLevelCase.rawValue).tag(staffLevelCase)
                        }
                    }
                    .focusable()
                    Toggle(isOn: $FirstForPage.onChange(firstForPageChanged)) {
                        Text("First feature on page")
                    }
                    .focusable()
                }
            }

            Group {
                // Feature script output
                HStack {
                    Text("Feature script:")
                    Button(action: {
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects([FeatureScript as NSString])
                        checkForPlaceholders(in: FeatureScript)
                    }, label: {
                        Text("Copy")
                            .padding(.horizontal, 20)
                    })
                }
                .frame(alignment: .leading)
                TextEditor(text: $FeatureScript)
                    .frame(minWidth: 400, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 200)

                // Comment script output
                HStack {
                    Text("Comment script:")
                    Button(action: {
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects([CommentScript as NSString])
                        checkForPlaceholders(in: CommentScript)
                    }, label: {
                        Text("Copy")
                            .padding(.horizontal, 20)
                    })
                }
                .frame(alignment: .leading)
                TextEditor(text: $CommentScript)
                    .frame(minWidth: 200, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 80, maxHeight: 160)

                // Original post script output
                HStack {
                    Text("Original post script:")
                    Button(action: {
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects([OriginalPostScript as NSString])
                        checkForPlaceholders(in: OriginalPostScript)
                    }, label: {
                        Text("Copy")
                            .padding(.horizontal, 20)
                    })
                }
                .frame(alignment: .leading)
                TextEditor(text: $OriginalPostScript)
                    .frame(minWidth: 200, maxWidth: .infinity, minHeight: 40, maxHeight: 80)
            }

            Group {
                // New membership picker and script output
                HStack {
                    Text("New membership script:")
                    Picker("New membership: ", selection: $NewMembership.onChange(newMembershipChanged)) {
                        ForEach(NewMembershipCase.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                    Button(action: {
                        let pasteBoard = NSPasteboard.general
                        pasteBoard.clearContents()
                        pasteBoard.writeObjects([NewMembershipScript as NSString])
                        checkForPlaceholders(in: NewMembershipScript)
                    }, label: {
                        Text("Copy")
                            .padding(.horizontal, 20)
                    })
                }
                .frame(alignment: .leading)
                TextEditor(text: $NewMembershipScript)
                    .frame(minWidth: 200, maxWidth: .infinity, minHeight: 80, maxHeight: 160)
            }
        }
        .padding()
        .frame(minWidth: 1024, minHeight: 1100)
        .textFieldStyle(.roundedBorder)
        .alert(
            AlertTitle,
            isPresented: $ShowingAlert,
            actions: {
                Button("OK", action: {})
            },
            message: {
                Text(AlertMessage)
            })
    }

    func membershipChanged(to value: MembershipCase) {
        updateScripts()
    }

    func userNameChanged(to value: String) {
        updateScripts()
        updateNewMembershipScripts()
    }

    func yourNameChanged(to value: String) {
        UserDefaults.standard.set(YourName, forKey: "YourName")
        updateScripts()
    }

    func pageChanged(to value: PageCase) {
        UserDefaults.standard.set(Page.rawValue, forKey: "Page")
        updateScripts()
    }

    func pageNameChanged(to value: String) {
        UserDefaults.standard.set(PageName, forKey: "PageName")
        updateScripts()
    }
    
    func pageStaffLevelChanged(to value: StaffLevelCase) {
        UserDefaults.standard.set(PageStaffLevel.rawValue, forKey: "StaffLevel")
        updateScripts()
    }
    
    func firstForPageChanged(to value: Bool) {
        updateScripts()
    }

    func newMembershipChanged(to value: NewMembershipCase) {
        updateNewMembershipScripts()
    }

    func checkForPlaceholders(in value: String) {
        let placeholders = matches(of: "\\[\\[([^\\]]*)\\]\\]", in: value)
        if placeholders.count != 0 {
            var placeholdersList = ""
            for placeholder in placeholders {
                placeholdersList += placeholder + "\n"
            }
            if !ShowingAlert {
                AlertTitle = "Remember to fill in the placeholders:"
                AlertMessage = placeholdersList
                ShowingAlert = true
            }
        }
    }
    
    func updateScripts() -> Void {
        if Membership == MembershipCase.none || UserName.isEmpty || YourName.isEmpty || (Page == PageCase.custom && PageName.isEmpty) {
            FeatureScript = ""
            OriginalPostScript = ""
            CommentScript = ""
        } else {
            var pageName: String
            var featureScriptTemplate: String
            var commentScriptTemplate: String
            var originalPostScriptTemplate: String
            if Page == PageCase.custom {
                pageName = PageName
                featureScriptTemplate = getTemplate("feature", table: PageName, first: FirstForPage)
                commentScriptTemplate = getTemplate("comment", table: PageName, first: FirstForPage)
                originalPostScriptTemplate = getTemplate("original post", table: PageName, first: FirstForPage)
            } else {
                pageName = Page.rawValue
                featureScriptTemplate = getTemplate("feature", table: Page.rawValue, first: FirstForPage)
                commentScriptTemplate = getTemplate("comment", table: Page.rawValue, first: FirstForPage)
                originalPostScriptTemplate = getTemplate("original post", table: Page.rawValue, first: FirstForPage)
            }
            FeatureScript = featureScriptTemplate
                .replacingOccurrences(of: "%%PAGENAME%%", with: pageName)
                .replacingOccurrences(of: "%%MEMBERLEVEL%%", with: Membership.rawValue)
                .replacingOccurrences(of: "%%USERNAME%%", with: UserName)
                .replacingOccurrences(of: "%%YOURNAME%%", with: YourName)
                .replacingOccurrences(of: "%%STAFFLEVEL%%", with: PageStaffLevel.rawValue)
            OriginalPostScript = originalPostScriptTemplate
                .replacingOccurrences(of: "%%PAGENAME%%", with: pageName)
                .replacingOccurrences(of: "%%MEMBERLEVEL%%", with: Membership.rawValue)
                .replacingOccurrences(of: "%%USERNAME%%", with: UserName)
                .replacingOccurrences(of: "%%YOURNAME%%", with: YourName)
                .replacingOccurrences(of: "%%STAFFLEVEL%%", with: PageStaffLevel.rawValue)
            CommentScript = commentScriptTemplate
                .replacingOccurrences(of: "%%PAGENAME%%", with: pageName)
                .replacingOccurrences(of: "%%MEMBERLEVEL%%", with: Membership.rawValue)
                .replacingOccurrences(of: "%%USERNAME%%", with: UserName)
                .replacingOccurrences(of: "%%YOURNAME%%", with: YourName)
                .replacingOccurrences(of: "%%STAFFLEVEL%%", with: PageStaffLevel.rawValue)
        }
    }

    func getTemplate(_ templateName: String, table: String, first: Bool) -> String {
        // If first for page
        var template: String = templateName
        
        // If looking for "first" template, check for that first in the "new" string catalog.
        if first {
            let needle = "first " + templateName
            template = String(localized: String.LocalizationValue(needle), table: "new_" + table)
            if template != needle {
                return template
            }
        }
        
        // Check for non-"first" template in the "new" string catalog.
        template = String(localized: String.LocalizationValue(templateName), table: "new_" + table)
        if template != templateName {
            return template
        }
        
        // If looking for "first" template, check for that next in the old strings dict.
        if first {
            let needle = "first " + templateName
            template = String(localized: String.LocalizationValue(needle), table: table)
            if template != needle {
                return template
            }
        }

        // Check for non-"first" template in the old strings dict.
        template = String(localized: String.LocalizationValue(templateName), table: table)
        if template != templateName {
            return template
        }
        
        // Did not find it in the table, try the default table.
        if table != "default" {
            template = getTemplate(templateName, table: "default", first: first)
        }

        return template
    }

    func updateNewMembershipScripts() -> Void {
        if NewMembership == NewMembershipCase.none || UserName == "" {
            NewMembershipScript = ""
        } else if NewMembership == NewMembershipCase.member {
            NewMembershipScript =
                "Congratulations @" + UserName + " on your 5th feature!\n" +
                "\n" +
                "I took the time to check the number of features you have with the SNAP Community and wanted to share with you that you are now a Member of the SNAP Community!\n" +
                "\n" +
                "That's an awesome achievement 👏🏼👏🏼💐💐💐💐💐💐.\n" +
                "\n" +
                "Please consider adding ✨ SNAP Community Member ✨ to your bio it will give you the chance to be featured in any raw page using only the membership tag.\n"
        } else if NewMembership == NewMembershipCase.vipMember {
            NewMembershipScript =
                "Congratulations @" + UserName + " on your 15th feature!\n" +
                "\n" +
                "I took the time to check the number of features you have with the SNAP Community and wanted to share that you are now a VIP Member of the SNAP Community!\n" +
                "\n" +
                "That's an awesome achievement 👏🏼👏🏼💐💐💐💐💐💐.\n" +
                "\n" +
                "Please consider adding ✨ SNAP VIP Member ✨ to your bio it will give you the chance to be featured in any raw page using only the membership tag."
        }
    }
}
