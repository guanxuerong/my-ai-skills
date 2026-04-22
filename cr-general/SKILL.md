---
name: cr-general
description: 通用前端代码走查，输出飞书文档报告（React + Antd 5）。当用户说"代码走查"、"code review"、"CR"、"走查"时自动触发。支持指定文件范围或基于需求文档自动确定范围。
---

# Skill: 前端代码走查

## 触发词
- 代码走查 / code review / CR / 走查
- 走查 [模块名/文件路径]
- 生成走查报告

## 两种使用模式

### 模式一：独立走查（无需求文档）
用户直接指定文件范围，AI 基于项目编码规范进行走查。

### 模式二：需求关联走查（有需求文档）
从 daily-workflow 的设计文档中读取"修改文件表格"，自动确定走查范围，并额外检查与设计文档的一致性。

## 执行流程

### 第一步：确认走查范围

**如果用户提供了文件范围**：直接使用。
**如果用户未提供**：询问以下信息：

1. **代码文件范围**（必填）：
   - 示例：`src/view/**/*.tsx`
   - 支持文件路径、文件夹路径、glob 模式
2. **关联需求文档**（可选）：飞书设计文档链接，提供后会额外检查与设计文档的一致性
3. **专项检查**（可选）：是否需要特定业务场景的专项检查（如 IP 联名套餐、营销活动等）

### 第二步：确认输出方式（可选）

询问用户走查报告的输出方式：

1. **直接输出到对话**（默认）：不写飞书，直接在对话中展示走查报告
2. **写入飞书文档**：用户提供飞书目录链接，或使用 Kiro 根目录

### 第三步：执行代码走查

按以下维度逐一分析代码文件：

#### 1. 代码规范检查
- [ ] 命名规范：变量/函数 camelCase，组件 PascalCase，常量 UPPER_SNAKE_CASE，boolean 用 is/has/should/can 前缀
- [ ] 函数风格：必须使用箭头函数表达式（func-style: expression），禁止 function 声明
- [ ] 类型定义：Props 必须有 interface 定义，避免 any（必要时用 unknown + 类型收窄）
- [ ] 日期库：禁止引入 moment，必须用 dayjs；DatePicker 从 antd 引入，禁止用 CompactV4Moment
- [ ] 导入规范：是否有重复导入（如同时 import {Form} from 'antd' 和 import type {FormInstance} from 'antd'）、未使用的导入
- [ ] 注释规范：接口函数必须有 JSDoc，复杂逻辑有行内注释，注释 // 后必须有空格
- [ ] 格式规范：无分号、单引号、花括号内无空格 {a, b}、单行不超过 120 字符、2 空格缩进
- [ ] 文件头：是否有 /** @format */ 文件头（Prettier 自动插入）
- [ ] 路径别名：是否正确使用 @/ 和 @@/ 别名，不要用相对路径跨层级引用
- [ ] 循环中的 ++：使用 i += 1 代替 i++（ESLint no-plusplus）

#### 2. 逻辑健壮性检查
- [ ] 空值保护：接口返回 null/undefined 时是否有兜底（可选链 `?.` 或默认值）
- [ ] JSON.parse 保护：所有 JSON.parse 调用是否有 try/catch 或封装为 safeJsonParse
- [ ] 数组/对象默认值：map/forEach 前是否有 `|| []` 或 `?.`；Object.keys() 前是否判断非空
- [ ] 状态一致性：多个相关 state 更新时是否保持一致（是否有冗余 state 可以从 form 或其他 state 派生）
- [ ] 条件渲染：是否有 0 值渲染异常（如 `list.length && <Component />` 会渲染 0）
- [ ] 条件判断完整性：三元/if-else 是否覆盖所有分支，是否有遗漏导致误渲染（如 selectRowParams 为空时走错分支）
- [ ] 错误处理：try/catch 是否覆盖关键异步操作，catch 中是否有用户提示
- [ ] 边界条件：数字精度（价格用分单位）、超长文本（ellipsis）、枚举值映射是否处理
- [ ] 表单重置：重置操作是否清空所有相关状态（form.resetFields + 关联的 state）

#### 3. 接口调用检查
- [ ] 请求时机：useEffect 依赖是否完整，是否导致请求死循环
- [ ] 加载状态：是否有 loading 状态防止重复操作（按钮 loading/disabled）
- [ ] 防重提交：表单提交是否有 debounce 或 loading 状态防止重复提交
- [ ] 错误处理：是否使用 message.error() 或 message.warning() 提示用户
- [ ] 竞态条件：快速切换页面/tab 时，旧请求响应是否被忽略
- [ ] 参数类型：number 类型参数是否传了 string（常见于表单取值）
- [ ] 接口类型定义：请求参数和响应是否有 TypeScript 类型定义
- [ ] 保存后刷新：保存成功后是否正确刷新列表/数据，是否有时序问题

#### 4. 性能与可维护性检查
- [ ] 冗余 state：是否有可以从 form 或其他 state 派生的冗余状态（如 keyWords 可以从 form.getFieldValue 获取）
- [ ] 重复代码：是否有可以提取为公共函数/组件的重复逻辑
- [ ] 组件大小：单文件是否超过 300 行，超出则拆分
- [ ] 函数长度：单函数是否超过 50 行
- [ ] 嵌套深度：是否超过 6 层嵌套（max-depth）
- [ ] 回调嵌套：是否超过 3 层回调嵌套（max-nested-callbacks）
- [ ] 大列表渲染：Table/List 是否使用 virtual 或 pagination
- [ ] 防抖搜索：搜索输入是否有防抖（>=300ms）
- [ ] 硬编码：是否有硬编码的值应该提取为常量（如 paramName 列表）
- [ ] useMemo/useCallback：是否仅在确实需要优化时使用，不要过度使用
- [ ] console.log：是否有遗留的调试代码
- [ ] 嵌套三元：是否有嵌套三元表达式（ESLint 禁止），改用 IIFE 或提取函数

#### 5. 交互与代码逻辑优化建议（P3）
- [ ] 滥用 useState：是否有可以用 useRef 或派生计算替代的 state
- [ ] 滥用 useMemo/useCallback：是否在不需要优化的场景过度使用，增加了复杂度
- [ ] Form.useWatch 风险：useWatch 监听的字段变化是否会触发不必要的重渲染
- [ ] 状态提升过度：是否有本应在子组件内部管理的 state 被提升到了父组件
- [ ] 未合并相关状态：多个紧密关联的 state 是否应该合并为一个对象（如 {loading, data, error}）
- [ ] 内联函数过多：JSX 中是否有大量内联函数/对象，应提取到组件外部或用 useCallback
- [ ] 冗余状态：是否有可以从 form、props 或其他 state 派生的冗余状态
- [ ] 不必要的副作用：useEffect 中是否有可以在事件处理函数中直接执行的逻辑
- [ ] 无限循环风险：useEffect 的依赖项是否在内部被修改，导致死循环
- [ ] 列表缺少稳定 key：map 渲染列表时是否使用 index 作为 key（应使用稳定唯一标识）
- [ ] 硬编码魔法数字/字符串：是否有未提取为常量的魔法值（如超时时间、阈值、配置项）
- [ ] 代码风格与命名：变量/函数命名是否语义清晰，是否有误导性命名

#### 6. 与设计文档一致性（仅模式二）
- [ ] 数据结构：实际代码中的数据结构是否与设计文档一致
- [ ] 组件设计：组件拆分是否与修改文件表格一致
- [ ] 接口调用：接口地址、参数、响应处理是否与接口文档一致
- [ ] 交互流程：用户操作流程是否与交互流程图一致

#### 7. 专项检查（可选，根据用户选择）

**IP 联名套餐专项**：
- [ ] 套餐价格计算：套餐价 vs 原价合计是否正确，是否使用分单位
- [ ] 时间判断：活动开始/结束时间，dayjs 时区处理是否正确
- [ ] 门店选择：TreeSelect/Select 新增和编辑时数据回显是否正常

**营销活动专项**：
- [ ] 优惠券/活动状态流转是否完整
- [ ] 活动时间范围校验是否正确
- [ ] 库存/数量边界是否处理

**Antd 升级专项**（任意版本升级后的重点关注范围）：

Table — 数据与性能：
- [ ] dataSource 为空时是否兜底，columns render 是否处理空值
- [ ] rowKey 是否稳定唯一，rowSelection 类型是否兼容
- [ ] 大数据量分页/虚拟滚动是否正常
- [ ] sorter/filter 受控模式状态更新是否正确

Form — 联动与校验：
- [ ] dependencies 联动是否触发重新校验
- [ ] setFieldsValue 与 initialValues 优先级是否符合预期
- [ ] useWatch 监听是否导致频繁重渲染
- [ ] 嵌套字段 name={['a', 'b']} 回显和提交是否正确
- [ ] 校验规则（rules）行为是否一致

Modal — 生命周期：
- [ ] destroyOnClose 关闭后表单/状态是否正确清理
- [ ] Modal 内 Form 打开时是否重新初始化
- [ ] forceRender 和 afterClose 行为是否符合预期

Select / Cascader：
- [ ] showSearch 搜索过滤是否正常
- [ ] 多选/labelInValue 模式下值类型是否兼容
- [ ] Cascader 异步加载行为是否正常

DatePicker：
- [ ] RangePicker disabledDate/disabledTime 限制是否生效
- [ ] value 类型（dayjs 对象）是否兼容
- [ ] 格式化输出是否一致

Upload：
- [ ] 受控 fileList 状态更新是否正确
- [ ] onChange 中各 status 处理是否完整
- [ ] beforeUpload 校验和返回值行为是否一致

> 用户可以自定义专项检查维度，AI 会根据描述生成对应检查项。

**React 升级专项**（17 → 18）：

入口文件变更：
- [ ] createRoot 替换 ReactDOM.render（入口文件 index.tsx）
- [ ] unmountComponentAtNode 替换为 root.unmount

自动批处理（Automatic Batching）：
- [ ] setTimeout/Promise/原生事件中的多次 setState 现在会自动合并，之前依赖"每次 setState 立即触发渲染"的逻辑是否受影响
- [ ] 需要立即刷新的场景是否用 flushSync 包裹

Strict Mode 行为变化：
- [ ] 开发模式下 useEffect 会执行两次（mount → unmount → mount），副作用是否幂等
- [ ] 接口请求是否因 double invoke 导致重复调用
- [ ] 事件监听/定时器是否在 cleanup 中正确清理

useEffect 清理时机：
- [ ] cleanup 函数现在在新的 effect 执行前同步运行，依赖此时序的逻辑是否正常

Suspense 与懒加载：
- [ ] React.lazy + Suspense 的路由懒加载是否正常（LazyComponent 实现）
- [ ] fallback 组件是否正确展示

第三方库兼容性：
- [ ] 状态管理库（redux/rematch/zustand 等）是否兼容 React 18
- [ ] 路由库（react-router-dom）是否需要升级
- [ ] 拖拽库（react-beautiful-dnd / @dnd-kit 等）是否兼容
- [ ] 微前端框架（qiankun / wujie 等）是否兼容
- [ ] 其他 React 生态库是否有兼容性问题

事件系统变化：
- [ ] 事件不再挂载到 document 而是 root 容器，微前端场景下事件冒泡是否受影响
- [ ] onFocus/onBlur 使用原生 focusin/focusout，表单聚焦行为是否一致

TypeScript 类型变化：
- [ ] children 不再隐式包含在 FC props 中，需显式声明 children?: React.ReactNode
- [ ] 组件返回类型允许 undefined，之前必须返回 null 的地方是否需要调整

### 第四步：生成报告并写入飞书

按以下模板生成报告，调用飞书 MCP 创建文档。

**文档标题格式**：
- 有关联需求：`[需求名]_AI走查报告`
- 无关联需求：`【CR】[模块名/日期]代码走查报告`

## 报告模板

```markdown
# [标题]

- **走查人**：AI + @{用户}
- **走查时间**：{当前日期}
- **代码范围**：{文件路径}
- **技术栈**：React + Antd 5+
- **关联需求**：{需求文档链接，无则填"独立走查"}

---

## 一、走查概览

| 维度 | 检查项数 | 通过 | 问题数 |
|------|----------|------|--------|
| 代码规范 | X | X | X |
| 逻辑健壮性 | X | X | X |
| 接口调用 | X | X | X |
| 性能与可维护性 | X | X | X |
| 优化建议(P3) | X | X | X |
| 设计文档一致性 | X | X | X |
| 专项检查 | X | X | X |

**整体评估**：[良好 / 存在风险 / 严重问题]

---

## 二、问题详情

| 序号 | 文件 | 问题类型 | 问题描述 | 严重程度 | 建议修复方案 | 是否已修复 |
|------|------|----------|----------|----------|--------------|------------|
| 1 | xxx.tsx | 代码规范 | xxx | P2 | xxx | 否 |
| 2 | xxx.tsx | 逻辑健壮性 | xxx | P1 | xxx | 否 |

严重程度：P0（紧急重要，必须现在就修改）/ P1（重要但不紧急，可以稍后改）/ P2（不是很关键，可以以后再改）/ P3（优化建议，提升代码质量和可维护性）

---

## 三、AI 建议

### 代码质量建议
1. [建议1]
2. [建议2]

### 风险提示
1. [提示1]
2. [提示2]

---

**报告生成时间**：{当前日期时间}
```

## 自我学习

CR 规范会根据实际走查中发现的新问题模式持续更新：
- 如果某类问题反复出现，新增到对应维度的检查项中
- 如果发现新的检查维度，新增章节
- 更新时遵循自我学习流程：识别→提出→用户确认→执行
