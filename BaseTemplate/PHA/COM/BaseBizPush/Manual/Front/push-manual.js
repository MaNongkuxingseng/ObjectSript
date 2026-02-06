const API_BASE = '/csp/pha/manual';

function queryTargets() {
  const req = {
    entryCode: $('#entryCode').textbox('getValue'),
    hospId: $('#hospId').textbox('getValue'),
    deptCode: $('#deptCode').textbox('getValue')
  };

  $.ajax({
    url: API_BASE + '/query',
    method: 'POST',
    contentType: 'application/json',
    data: JSON.stringify(req),
    success: function(resp) {
      if (!resp.success) {
        $.messager.alert('提示', resp.message || '查询失败');
        return;
      }
      $('#targetGrid').datagrid('loadData', resp.targets || []);
    },
    error: function(xhr) {
      $.messager.alert('错误', '查询异常: ' + xhr.statusText);
    }
  });
}

function executePush() {
  const checked = $('#targetGrid').datagrid('getChecked') || [];
  const targetClasses = checked.map(x => x.targetClass);
  let bizInfo = {};
  const bizText = $('#bizInfoJson').textbox('getValue');
  if (bizText) {
    try { bizInfo = JSON.parse(bizText); }
    catch (e) {
      $.messager.alert('提示', 'bizInfo JSON格式错误');
      return;
    }
  }

  const req = {
    entryCode: $('#entryCode').textbox('getValue'),
    hospId: $('#hospId').textbox('getValue'),
    deptCode: $('#deptCode').textbox('getValue'),
    bizInfo: bizInfo,
    targetClasses: targetClasses
  };

  $.ajax({
    url: API_BASE + '/execute',
    method: 'POST',
    contentType: 'application/json',
    data: JSON.stringify(req),
    success: function(resp) {
      $('#resultGrid').datagrid('loadData', resp.results || []);
      const msg = `执行完成: success=${resp.successCount||0}, failure=${resp.failureCount||0}`;
      $.messager.alert('结果', msg);
    },
    error: function(xhr) {
      $.messager.alert('错误', '执行异常: ' + xhr.statusText);
    }
  });
}
