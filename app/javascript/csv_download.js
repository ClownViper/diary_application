// Download CSV via fetch + Blob. iOS Safari opens an attachment (even with a
// download attribute) in an in-app viewer with no way back; fetching the file
// and saving it as a Blob URL forces a real download without leaving the page.
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("a[data-csv-download]").forEach((link) => {
    link.addEventListener("click", async (event) => {
      event.preventDefault();
      try {
        const res = await fetch(link.href, { headers: { Accept: "text/csv" } });
        if (!res.ok) throw new Error("fetch failed");

        const disposition = res.headers.get("Content-Disposition") || "";
        const match = disposition.match(/filename="?([^"]+)"?/);
        const filename = match ? match[1] : "export.csv";

        const blob = await res.blob();
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = filename;
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
      } catch {
        window.location.href = link.href; // fallback to normal navigation
      }
    });
  });
});
