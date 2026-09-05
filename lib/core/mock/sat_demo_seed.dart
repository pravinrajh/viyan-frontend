import '../../features/meetings/models/meeting.dart';
import '../../features/tasks/models/task.dart';

/// Shared SAT-demo seed used by mock repositories.
/// Business records stay relational (projects ↔ tasks ↔ meetings).
/// Widgets never import this file.
abstract final class SatDemoSeed {
  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static List<Task> tasks() {
    final today = _today;
    return [
      Task(
        id: 'task-1',
        title: 'Approve OMR Commercial foundation variation',
        description: 'High-risk site. Structural variation needs MD sign-off before pour.',
        status: TaskStatus.overdue,
        priority: TaskPriority.critical,
        owner: 'Raj',
        dueDate: today.subtract(const Duration(days: 1)),
        createdAt: today.subtract(const Duration(days: 5)),
        projectId: 'prj-3',
        projectName: 'OMR Commercial',
        customerName: 'XYZ Developers',
      ),
      Task(
        id: 'task-2',
        title: 'Follow up ABC Builders collection',
        description: '₹48 L outstanding on Chennai Villa milestone 3.',
        status: TaskStatus.pending,
        priority: TaskPriority.critical,
        owner: 'Meena',
        dueDate: today,
        createdAt: today.subtract(const Duration(days: 3)),
        projectId: 'prj-1',
        projectName: 'Chennai Villa',
        customerName: 'ABC Builders',
      ),
      Task(
        id: 'task-3',
        title: 'Vendor settlement — Sri Materials',
        description: 'Steel invoice pending approval for Coimbatore Interior.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        owner: 'Procurement',
        dueDate: today.add(const Duration(days: 1)),
        createdAt: today.subtract(const Duration(days: 4)),
        projectId: 'prj-2',
        projectName: 'Coimbatore Interior',
        vendorName: 'Sri Materials',
      ),
      Task(
        id: 'task-4',
        title: 'Site visit — Chennai Villa finishing',
        description: 'Review flooring and joinery quality with PM.',
        status: TaskStatus.pending,
        priority: TaskPriority.high,
        owner: 'Raj',
        dueDate: today.add(const Duration(days: 1)),
        createdAt: today.subtract(const Duration(days: 2)),
        projectId: 'prj-1',
        projectName: 'Chennai Villa',
        customerName: 'ABC Builders',
        reminderAt: today.add(const Duration(hours: 16)),
      ),
      Task(
        id: 'task-5',
        title: 'Legal pack for OMR land parcel',
        description: '12-acre parcel under legal verification.',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        owner: 'Legal',
        dueDate: today.add(const Duration(days: 3)),
        createdAt: today.subtract(const Duration(days: 10)),
        projectId: 'prj-3',
        projectName: 'OMR Commercial',
      ),
      Task(
        id: 'task-6',
        title: 'Call Kumar Residence on proposal',
        description: 'Lead in negotiation. Estimated ₹1.2 Cr villa.',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        owner: 'Sales Head',
        dueDate: today.add(const Duration(days: 2)),
        createdAt: today.subtract(const Duration(days: 1)),
        customerName: 'Kumar Residence',
      ),
      Task(
        id: 'task-7',
        title: 'Weekly cash forecast',
        description:
            'Treasury draft covering labour, vendor and land payments.',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        owner: 'Treasury',
        dueDate: today.add(const Duration(days: 2)),
        createdAt: today.subtract(const Duration(days: 1)),
      ),
      Task(
        id: 'task-8',
        title: 'Green Homes site visit scheduling',
        description: 'Qualified lead. Arrange OMR plot walkthrough.',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        owner: 'Sales Head',
        dueDate: today.add(const Duration(days: 4)),
        createdAt: today,
        customerName: 'Green Homes',
      ),
      Task(
        id: 'task-9',
        title: 'Release labour payment — Chennai Villa',
        description: 'Week 32 labour bill cleared by PM.',
        status: TaskStatus.completed,
        priority: TaskPriority.medium,
        owner: 'Finance',
        dueDate: today.subtract(const Duration(days: 2)),
        createdAt: today.subtract(const Duration(days: 7)),
        projectId: 'prj-1',
        projectName: 'Chennai Villa',
      ),
      Task(
        id: 'task-10',
        title: 'ERP attendance export blocked',
        description: 'Blocked on vendor patch for payroll mapping.',
        status: TaskStatus.cancelled,
        priority: TaskPriority.high,
        owner: 'IT',
        dueDate: today.add(const Duration(days: 5)),
        createdAt: today.subtract(const Duration(days: 12)),
        vendorName: 'ERP Soft',
      ),
    ];
  }

  static List<Meeting> meetings() {
    final today = _today;
    return [
      Meeting(
        id: 'mtg-1',
        title: 'Leadership standup',
        startAt: today.add(const Duration(hours: 9)),
        endAt: today.add(const Duration(hours: 9, minutes: 30)),
        location: 'MD cabin',
        attendees: const ['EA', 'COO', 'CFO'],
        status: 'confirmed',
      ),
      Meeting(
        id: 'mtg-2',
        title: 'Chennai Villa progress review',
        startAt: today.add(const Duration(hours: 11)),
        endAt: today.add(const Duration(hours: 11, minutes: 45)),
        location: 'War room',
        attendees: const ['Raj', 'PM', 'ABC Builders'],
        status: 'confirmed',
      ),
      Meeting(
        id: 'mtg-3',
        title: 'Banker call — working capital',
        startAt: today.add(const Duration(hours: 14)),
        endAt: today.add(const Duration(hours: 14, minutes: 45)),
        location: 'Conference line',
        attendees: const ['CFO', 'Treasury'],
        status: 'confirmed',
      ),
      Meeting(
        id: 'mtg-4',
        title: 'OMR Commercial risk huddle',
        startAt: today.add(const Duration(hours: 16, minutes: 30)),
        endAt: today.add(const Duration(hours: 17, minutes: 15)),
        location: 'Projects office',
        attendees: const ['Raj', 'Structural', 'Legal'],
        status: 'confirmed',
      ),
      Meeting(
        id: 'mtg-5',
        title: 'Green Homes site visit',
        startAt: today.add(const Duration(days: 1, hours: 10)),
        endAt: today.add(const Duration(days: 1, hours: 11)),
        location: 'OMR plot',
        attendees: const ['Sales Head', 'Green Homes'],
        status: 'tentative',
      ),
    ];
  }
}
