// SANITIZED_STATIC_REVIEW_COPY; raw source SHA256 df1ba470b9f79d0e51f925140b50b4c1b7399aeb49792fee827d18816a0d2cda
package elitesync.task;

import com.android.uiautomator.core.Configurator;
import com.android.uiautomator.core.UiDevice;
import com.android.uiautomator.core.UiObject;
import com.android.uiautomator.core.UiSelector;
import com.android.uiautomator.testrunner.UiAutomatorTestCase;
import java.io.File;
import java.io.FileOutputStream;
import android.graphics.Rect;
import android.util.Xml;
import android.view.accessibility.AccessibilityNodeInfo;
import org.xmlpull.v1.XmlSerializer;

/** Task-owned UI test using the installed platform's public UIAutomator API. */
public class CurrentTreeTest extends UiAutomatorTestCase {
  private static final String PKG = "com.elitesync.v1015r1dev";
  private static class OwnedRoot extends UiObject {
    OwnedRoot() { super(new UiSelector().packageName(PKG)); }
    AccessibilityNodeInfo current() { return findAccessibilityNodeInfo(0); }
  }
  private void writeNode(XmlSerializer xml, AccessibilityNodeInfo node, int depth, int[] count) throws Exception {
    if (node == null || depth > 35 || count[0] >= 250 || !PKG.contentEquals(node.getPackageName() == null ? "" : node.getPackageName())) return;
    Rect bounds = new Rect();
    node.getBoundsInScreen(bounds);
    if (node.isVisibleToUser() && bounds.width() > 0 && bounds.height() > 0) {
      xml.startTag(null, "node");
      xml.attribute(null, "package", PKG);
      xml.attribute(null, "class", node.getClassName() == null ? "" : node.getClassName().toString());
      xml.attribute(null, "text", node.getText() == null ? "" : node.getText().toString());
      xml.attribute(null, "content-desc", node.getContentDescription() == null ? "" : node.getContentDescription().toString());
      xml.attribute(null, "clickable", Boolean.toString(node.isClickable()));
      xml.attribute(null, "enabled", Boolean.toString(node.isEnabled()));
      xml.attribute(null, "bounds", "[" + bounds.left + "," + bounds.top + "][" + bounds.right + "," + bounds.bottom + "]");
      xml.endTag(null, "node");
      count[0]++;
    }
    for (int i = 0; i < node.getChildCount(); i++) {
      AccessibilityNodeInfo child = node.getChild(i);
      if (child != null) { writeNode(xml, child, depth + 1, count); child.recycle(); }
    }
  }
  public void testCurrentProjectTree() throws Exception {
    String name = getParams().getString("output");
    assertTrue(name != null && name.matches("[A-Za-z0-9_-]+[.]xml"));
    Configurator config = Configurator.getInstance();
    long previous = config.getWaitForIdleTimeout();
    long selectorPrevious = config.getWaitForSelectorTimeout();
    try {
      // Synchronization preference in this test process only, not a system or
      // permission setting. Live media need not become idle for a snapshot.
      config.setWaitForIdleTimeout(0);
      config.setWaitForSelectorTimeout(0);
      UiDevice device = getUiDevice();
      assertEquals("com.elitesync.v1015r1dev", device.getCurrentPackageName());
      int[] count = new int[]{0};
      AccessibilityNodeInfo root = new OwnedRoot().current();
      assertNotNull(root);
      try (FileOutputStream out = new FileOutputStream("/data/local/tmp/" + name)) {
        XmlSerializer xml = Xml.newSerializer();
        xml.setOutput(out, "UTF-8");
        xml.startDocument("UTF-8", true);
        xml.startTag(null, "hierarchy");
        writeNode(xml, root, 0, count);
        xml.endTag(null, "hierarchy");
        xml.endDocument();
      }
      root.recycle();
      assertTrue(count[0] > 0 && count[0] < 250);
      assertTrue(new File("/data/local/tmp/" + name).isFile());
    } finally {
      config.setWaitForIdleTimeout(previous);
      config.setWaitForSelectorTimeout(selectorPrevious);
    }
  }

  private AccessibilityNodeInfo findOpen(AccessibilityNodeInfo node) {
    if (node == null || !PKG.contentEquals(node.getPackageName() == null ? "" : node.getPackageName())) return null;
    if (node.isVisibleToUser() && node.isClickable() && "打开所属页面".contentEquals(node.getContentDescription() == null ? "" : node.getContentDescription())) return AccessibilityNodeInfo.obtain(node);
    for (int i=0; i<node.getChildCount(); i++) {
      AccessibilityNodeInfo child=node.getChild(i);
      if(child!=null) {
        AccessibilityNodeInfo result=findOpen(child);child.recycle();
        if(result!=null)return result;
      }
    }
    return null;
  }
  public void testClickCurrentNotification() throws Exception {
    File trigger=new File("/data/local/tmp/elitesync-r1-notification-go-20261025");
    assertFalse(trigger.exists());
    Configurator config=Configurator.getInstance();
    long idle=config.getWaitForIdleTimeout(), selector=config.getWaitForSelectorTimeout();
    try {
      config.setWaitForIdleTimeout(0);config.setWaitForSelectorTimeout(0);
      System.out.println("ELITESYNC_R1_CLICK_READY");
      long deadline=android.os.SystemClock.elapsedRealtime()+45000;
      while(!trigger.exists() && android.os.SystemClock.elapsedRealtime()<deadline)Thread.sleep(10);
      assertTrue("GO not received",trigger.exists());
      assertEquals(PKG,getUiDevice().getCurrentPackageName());
      AccessibilityNodeInfo root=new OwnedRoot().current();assertNotNull(root);
      AccessibilityNodeInfo target=findOpen(root);root.recycle();
      if(target==null){System.out.println("ELITESYNC_R1_CLICK outcome=NOT_VISIBLE");return;}
      try {
        boolean clicked=target.performAction(AccessibilityNodeInfo.ACTION_CLICK);
        System.out.println("ELITESYNC_R1_CLICK outcome="+(clicked?"CLICK_DISPATCHED":"ACTION_REJECTED"));
      }finally{target.recycle();}
    }finally{config.setWaitForIdleTimeout(idle);config.setWaitForSelectorTimeout(selector);}
  }
}
