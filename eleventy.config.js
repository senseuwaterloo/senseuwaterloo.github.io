import pluginWebc from "@11ty/eleventy-plugin-webc";

export default function (config) {
  config.setInputDirectory("src");
  config.addPlugin(pluginWebc, {
    components: [
      "src/_includes/components/**/*.webc",
    ],
    useTransform: true,
  });
  config.addGlobalData("layout", "layouts/base");

  // Images live alongside the uploaded source in upload/; copy them to /images.
  config.addPassthroughCopy({ "upload/images": "images" });
  // Publication PDFs.
  config.addPassthroughCopy("pubs");
}
