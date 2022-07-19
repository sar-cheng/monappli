namespace monappli.Windows
{
    /// <summary>
    /// Interaction logic for MyTrackers.xaml
    /// </summary>
    public partial class MyTrackers : Window
    {
        public MyTrackers()
        {
            InitializeComponent();
            DataContext = this;

            PageTitle.Text = "MY TRACKERS - " + MonthService.Month;
            if (!CurrentHabit.AreDatesLoaded)
            {
                MonthService.PrepareCollections();
                CurrentHabit.AreDatesLoaded = true; 
            } 
            LoadDates(); //duplciates, reusing same window but rerunning this section of code

            if (IsFirstDayofMonth())
                ClearHabits();
            else 
                LoadHabits();

        }
        public void UpdateHabit()
        {
            foreach (Habit habit in HabitsList)
            {
                if (habit.HabitName == SelectedHabit)
                {
                    habit.HabitName = CurrentHabit.Name;
                }
            }
        }
        static bool IsFirstDayofMonth()
        {
            if (DateTime.Today.Day == 1) 
                return true;
            else 
                return false;
        }
        public ObservableCollection<Habit> HabitsList { get; set; } = new();
        public ObservableCollection<string> DaysOfWeek { get; set; } = new();
        public ObservableCollection<string> DaysOfMonth { get; set; } = new();
        public void LoadDates()
        {
            for (int i = 0; i < MonthService.DaysOfWeek.Count; i++)
            {
                DaysOfWeek.Add(MonthService.DaysOfWeek[i]);
                DaysOfMonth.Add(MonthService.DaysOfMonth[i]);
            }
        }
        #region MenuButtons
        private void HomeButton_Click(object sender, RoutedEventArgs e)
            => DataService.ChangeWindow(this, new MainWindow());
        private void ToDoButton_Click(object sender, RoutedEventArgs e)
            => DataService.ChangeWindow(this, new ToDo());
        private void TrackersButton_Click(object sender, RoutedEventArgs e)
            => DataService.ChangeWindow(this, this);
        private void EntriesButton_Click(object sender, RoutedEventArgs e)
            => DataService.ChangeWindow(this, new MyEntries());
        #endregion
        public static string GetName(string filename) => filename.Remove(filename.Length - 4); //remove last 4 chars to remove .txt
        public static string NewName()
            => DataService.PreventDuplicateTitles("New habit", DataService.DataType.Habit);
        public ObservableCollection<Selection> NewChecks()
        {
            ObservableCollection<Selection> selections = new();
            for (int i = 0; i < DaysOfMonth.Count; i++)
                selections.Add(new Selection() { IsSelected = false });
            return selections;
        }
        private void NewHabit(object sender, RoutedEventArgs e)
           => HabitsList.Add(new Habit() { HabitName = NewName(), HabitChecks = NewChecks() });
        public static void ClearHabits()
        {
            string folder = DataService.GetPath("Habits");
            foreach (string file in Directory.EnumerateFiles(folder, ".txt"))
                File.Delete(file);
        }
        public void LoadHabits()
        {
            string folder = DataService.GetPath("Habits");
            foreach (string file in Directory.EnumerateFiles(folder, "*.txt"))
            {
                string filename = System.IO.Path.GetFileName(file);
                if (filename != "!!ALL HABITS.txt")
                {
                    string habitname = GetName(filename);
                    ObservableCollection<Selection> habitchecks = new();
                    foreach (string line in File.ReadLines(file))
                        habitchecks.Add(new Selection() { IsSelected = Convert.ToBoolean(line) });

                    HabitsList.Add(new Habit() { HabitName = habitname, HabitChecks = habitchecks });
                }
            }
        }
        public void UpdateHabitFile()
        {
            string oldpath = DataService.GetPath("Habits/" + SelectedHabit + ".txt");
            string newpath = DataService.GetPath("Habits/" + CurrentHabit.Name + ".txt");
            File.Move(oldpath, newpath); //save all habits first then update

            var oldlines = File.ReadAllLines(DataService.Paths.AllHabits);
            var newlines = oldlines.Select(x => x.Replace(SelectedHabit, CurrentHabit.Name)).ToArray();

            File.WriteAllLines(DataService.Paths.AllHabits, newlines);
        }
        private async void EditHabit_Click(object sender, RoutedEventArgs e)
        {
            if (IsHabitSelected)
            {
                CurrentHabit.Name = SelectedHabit;
                new EditHabit().Show();

                while (CurrentHabit.Name == SelectedHabit && !CurrentHabit.NameLeftUnchanged)
                {
                    IsEnabled = false;
                    await Task.Delay(1000);
                }

                IsEnabled = true;
                if (!CurrentHabit.NameLeftUnchanged)
                {
                    ClearOldFiles();
                    ResetList();
                    UpdateHabit();
                    SaveHabits();

                    LoadHabits();
                }
            }
            else MessageBox.Show("No habit selected");
        }
        private void DeleteHabit_Click(object sender, RoutedEventArgs e)
        {
            if (IsHabitSelected)
            {
                //var allhabits = File.ReadAllLines(DataService.Paths.AllHabits);
                string filepath = DataService.GetPath("Habits/" + SelectedHabit + ".txt");
                File.Delete(filepath);

                var oldlines = File.ReadAllLines(DataService.Paths.AllHabits);
                var newlines = oldlines.Where(line => !line.Contains(SelectedHabit)).ToArray();

                File.WriteAllLines(DataService.Paths.AllHabits, newlines);

                HabitsList.Remove(HabitsList[0]);
                DataService.ChangeWindow(this, new MainWindow());
            }
            else MessageBox.Show("No habit selected");
        }
        #region Closing
        public static void ClearOldFiles()
        {
            string folderpath = DataService.GetPath("Habits");
            foreach (string file in Directory.EnumerateFiles(folderpath, "*.txt"))
                File.Delete(file);
        }
        public static void ResetList()
            => File.WriteAllText(DataService.Paths.AllHabits, string.Empty);
        public void SaveHabits()
        {
            foreach (Habit habit in HabitsList)
            {
                habit.HabitName = DataService.PreventDuplicateTitles(habit.HabitName, DataService.DataType.Habit);
                using StreamWriter sw = File.AppendText(DataService.Paths.AllHabits);
                sw.WriteLine(habit.HabitName);

                string path = DataService.GetPath("Habits/" + habit.HabitName + ".txt");
                using StreamWriter sw2 = File.CreateText(path);
                foreach (Selection selection in habit.HabitChecks)
                    sw2.WriteLine(selection.IsSelected); //would checks update??
            }
        }
        private void Window_Closing(object sender, CancelEventArgs e)
        {
            ClearOldFiles();
            ResetList();
            SaveHabits();
        }
        #endregion
        bool IsHabitSelected { get; set; } = false;
        string SelectedHabit { get; set; } = string.Empty;
        private void HabitTitle_Click(object sender, RoutedEventArgs e)
        {
            var senderbtn = sender as Button;
            string currenthabit = senderbtn.Content.ToString();
            if (IsHabitSelected)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
            {
                if (SelectedHabit == currenthabit)
                {
                    senderbtn.Background = new SolidColorBrush(Colors.Transparent);
                    IsHabitSelected = false;
                    SelectedHabit = string.Empty;
                }
            }
            else
            {
                senderbtn.Background = new SolidColorBrush(Colors.LightBlue);
                IsHabitSelected = true;
                SelectedHabit = currenthabit;
            }
        }
    }
    #region Classes
    public class MonthService
    {
        public static ObservableCollection<string> DaysOfWeek { get; set; } = new();
        public static ObservableCollection<string> DaysOfMonth { get; set; } = new();
        public static int CurrentYear => Convert.ToInt32(DateTime.Now.Year);
        public static int CurrentMonth => Convert.ToInt32(DateTime.Now.Month);
        public static int CurrentMonthLength => DateTime.DaysInMonth(CurrentYear, CurrentMonth);
        public static string Month
            = CurrentMonth switch
            {
                1 => "January",
                2 => "February",
                3 => "March",
                4 => "April",
                5 => "May",
                6 => "June",
                7 => "July",
                8 => "August",
                9 => "September",
                10 => "October",
                11 => "November",
                12 => "December",
                _ => throw new NotImplementedException(),
            };
        public static void PrepareCollections()
        {
            for (int day = 1; day <= CurrentMonthLength; day++)
            {
                DaysOfWeek.Add(Convert.ToString(new DateTime(CurrentYear, CurrentMonth, day).DayOfWeek));
                DaysOfMonth.Add(day.ToString());
            }
        }
    }

    public class Habit
    {
        public Habit() { }
        public Habit(string habitname, ObservableCollection<Selection> habitchecks)
            => (HabitName, HabitChecks) = (habitname, habitchecks);
        public string HabitName { get; set; }
        public ObservableCollection<Selection> HabitChecks { get; set; } = new();
    }
    public class Selection
    {
        public Selection() { }
        public Selection(bool isSelected)
            => (IsSelected) = (isSelected);
        public bool IsSelected { get; set; }
    }
    #endregion
}

