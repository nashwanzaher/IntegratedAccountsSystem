using System;
using System.Data;
using System.Windows.Forms;
using IntegratedAccSys.BL.Users;

namespace IntegratedAccSys.PL.Security
{
    /// <summary>
    /// Applies screen-level privileges to a Form's standard action buttons.
    /// Lives in the PL layer because it directly manipulates UI controls.
    ///
    /// Buttons controlled (all optional, default-deny if missing):
    ///   btnNew, btnAdd, btnEdit, btnDel, btnPrint
    ///
    /// Reads user/branch from the PL's static Program context, then delegates
    /// data lookup to BL.Users.clsUsers.
    /// </summary>
    public static class PrivilegeApplier
    {
        /// <summary>
        /// Looks up the current user's privileges for the given windowID and
        /// enables/disables the form's standard action buttons accordingly.
        /// Default-deny: if no privilege row exists, all action buttons are disabled.
        /// </summary>
        public static void Apply(Form form, int windowID)
        {
            if (form == null) return;

            ClsUsers users = new ClsUsers();

            // Resolve user code from current logged-in user (Program state)
            DataTable userDt = users.getUserNo(Program.userName, Program.braCode);
            if (userDt.Rows.Count == 0) return;

            int userCode = Convert.ToInt32(userDt.Rows[0][0]);
            DataTable dt = users.getScreensPrivillages(userCode, windowID, Program.braCode);

            // Default-deny
            if (dt.Rows.Count == 0)
            {
                SetAllButtonsEnabled(form, false);
                return;
            }

            DataRow row = dt.Rows[0];
            ApplyButton(form, "btnNew", row, "privNew");
            ApplyButton(form, "btnAdd", row, "privAdd");
            ApplyButton(form, "btnEdit", row, "privEdit");
            ApplyButton(form, "btnDel", row, "privDel");
            ApplyButton(form, "btnPrint", row, "privPrint");
        }

        private static void ApplyButton(Form form, string buttonName, DataRow row, string columnName)
        {
            Control[] controls = form.Controls.Find(buttonName, true);
            if (controls.Length == 0) return;
            controls[0].Enabled = row[columnName] != DBNull.Value && (bool)row[columnName];
        }

        private static void SetAllButtonsEnabled(Form form, bool enabled)
        {
            string[] buttonNames = { "btnNew", "btnAdd", "btnEdit", "btnDel", "btnPrint" };
            foreach (string name in buttonNames)
            {
                Control[] controls = form.Controls.Find(name, true);
                if (controls.Length > 0)
                    controls[0].Enabled = enabled;
            }
        }
    }
}
