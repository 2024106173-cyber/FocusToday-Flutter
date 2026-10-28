# 전시우 Flutter 期中项目：交付与使用说明

## 已做好的内容

本项目沿用你上课登记的“1号：待办事项管理 App”，选 Google Tasks 为参考，提出独立的 v2 界面“오늘한눈”。其中有：

1. 韩文企划文件（真实商店评论、Persona、用户旅程、鱼骨图与 5 Why）
2. P01–P10 页面规划与界面状态说明
3. Flutter UI 源码和模拟任务数据（json-server 的 GET）
4. AI 反驳/再反驳的**待本人审核草案**、Prompt Log
5. 韩文 6 分钟讲稿
6. 7 页正文 + B1–B5 附录的 PPTX 和 PDF

## 必须知道的限制

本制作环境没有 Flutter SDK，**没有实际启动 Flutter 编译或录制运行视频**。因此目前交付的是完整的项目源代码与资料，代码仍须在你的电脑上运行确认。

另外，原始 App Store/Google Play 评论的个人星级和星级分布图没有可靠的文本数据，不能乱填。老师要求的是可查证的真实截图。你需要打开 [Google Tasks Google Play 页面](https://play.google.com/store/apps/details?hl=ko&id=com.google.android.apps.tasks)，截取：

- 应用总评分与各星级分布
- 2026-05-20、2026-08-27、2026-09-29 的三条评论（姓名遮住，确认各自星级）
- 原版 Google Tasks 的任务列表界面

把这些截图插到 B1 或原课程模板相应位置，在文档中替换“原本确认需要”的标记。不要捏造星级。

## Windows 运行步骤

1. 安装 Flutter SDK、Android Studio（模拟器）及 Node.js。
2. 解压本项目，打开 PowerShell。
3. 第一窗口进入 mock_server 文件夹执行：

~~~powershell
npm install
npm start
~~~

4. 第二窗口进入项目根目录执行：

~~~powershell
flutter doctor
flutter create . --platforms=android,web
flutter pub get
flutter run
~~~

5. 在 AndroidManifest.xml 添加 INTERNET 权限；如本地 HTTP 被系统阻止，开发阶段设置允许 cleartextTraffic。具体写法见 README.md。
6. 模拟器里检查：今天 → 快速添加 → 完成 → 完成箱 → 返回 → 右上角状态菜单。
7. 用 Windows 录屏、OBS 或手机录屏，制作 1 分钟演示视频。上传成别人可访问的链接。

## GitHub 上传（无需真的部署）

- 在 GitHub 创建一个空仓库，比如 focus-today-midterm。
- 把本项目整个文件夹中的 README、lib、mock_server、docs、pubspec.yaml 等推送上去。
- 需要在最终 PPT 第 7 页填入真实仓库 URL 和视频 URL。
- 如果课程提供的 mid-project-template 和 mid-project-presentation-template 文件可下载，**必须用老师的模板核对结构与版式**。目前你上传的是截图，不是模板源文件，所以 PPT 是按说明制作的结构对应版。

## 重要提交时间

**2026 年 10 月 29 日（星期四）下午 3:00 前，韩国时间**上传 LMS。请留出运行、录屏、上传时间。

## 哪些还需要你本人做

- 核对并完善真实截图与评论星级
- 确认“我的再反驳”确实代表你的真实判断
- 自己运行 Flutter 并录视频
- GitHub 上传与 LMS 最终提交

我们没有替你执行 GitHub 上传或 LMS 提交，也没有声称已完成用户测试。
