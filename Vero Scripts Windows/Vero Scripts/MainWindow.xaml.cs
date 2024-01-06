using System;
using System.Windows;
using FramePFX.Themes;
using Microsoft.Win32;

namespace Vero_Scripts
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
            if (IsLightTheme())
            {
                ThemesController.SetTheme(ThemeType.LightTheme);
            }
        }

        private static bool IsLightTheme()
        {
            using var key = Registry.CurrentUser.OpenSubKey(@"Software\Microsoft\Windows\CurrentVersion\Themes\Personalize");
            var value = key?.GetValue("AppsUseLightTheme");
            return value is int i && i > 0;
        }

        private void OnCopyFeatureScriptClick(object sender, RoutedEventArgs e)
        {
            var viewModel = DataContext as ScriptsViewModel;
            if (viewModel != null)
            {
                Clipboard.SetText(viewModel.FeatureScript);
            }
        }

        private void OnCopyCommentScriptClick(object sender, RoutedEventArgs e)
        {
            var viewModel = DataContext as ScriptsViewModel;
            if (viewModel != null)
            {
                Clipboard.SetText(viewModel.CommentScript);
            }
        }

        private void OnCopyOriginalPostScriptClick(object sender, RoutedEventArgs e)
        {
            var viewModel = DataContext as ScriptsViewModel;
            if (viewModel != null)
            {
                Clipboard.SetText(viewModel.OriginalPostScript);
            }
        }

        private void OnCopyNewMembershipScriptClick(object sender, RoutedEventArgs e)
        {
            var viewModel = DataContext as ScriptsViewModel;
            if (viewModel != null)
            {
                Clipboard.SetText(viewModel.NewMembershipScript);
            }
        }
    }
}