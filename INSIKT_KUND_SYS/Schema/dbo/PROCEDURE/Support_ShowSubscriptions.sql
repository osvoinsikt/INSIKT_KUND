SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Support_ShowSubscriptions] as
select 
           SubscriptionID = s.ID
           ,SubscriptionName = s.Name
           ,Schedule =
                      case t.Period
                                 when 'day' then
                                            'Every day at ' + cast(t.HourOfDay as varchar(12)) + ':00'
                                 when 'week' then
                                            'Weekly every: ' +
                                                      STUFF
                                                      (
                                                                 case when t.Monday = 1 then ', Monday' else '' end
                                                                 + case when t.Tuesday = 1 then ', Tuesday' else '' end
                                                                 + case when t.Wednesday = 1 then ', Wednesday' else '' end
                                                                 + case when t.Thursday = 1 then ', Thursday' else '' end
                                                                 + case when t.Friday = 1 then ', Friday' else '' end
                                                                 + case when t.Saturday = 1 then ', Saturday' else '' end
                                                                 + case when t.Sunday = 1 then ', Sunday' else '' end
                                                                 ,1,2,''
                                                      )
                                                      + ' at ' + cast(t.HourOfDay as varchar(12)) + ':00'
                                 when 'month' then
                                            'Monthly at day ' + CAST(t.Day as varchar(12)) + ' '+ cast(t.HourOfDay as varchar(12)) + ':00'
                                 else
                                            t.Period
                      end
           ,Report = r.Name

from 
           Subscription s
                      inner join SubscriptionReportRelation sr on
                                 sr.SubscriptionID= s.ID
                      inner join Report r on
                                 r.ID = sr.ReportID
                      inner join SubscriptionScheduleRelation ss on
                                 ss.SubscriptionID = s.ID
                      inner join Schedule t on
                                 t.ID = ss.ScheduleID             
order by
           s.ID
           ,r.Name
           
                      

select 
           SubscriptionID = s.ID
           ,SubscriptionName = s.Name
           ,UserID = ur.UserID
           ,UserName = isnull(u.UserName, 'Removed user: ' + sgu.UserName) 
           ,UserFullName = isnull(u.FullName, 'Removed user: ' + sgu.FullName)
           ,UserEmail = u.EmailAdress
           ,GroupID = gr.GroupID
           ,GroupName = g.Name
           
from 
           Subscription s
                      inner join SubscriptionReportRelation sr on
                                 sr.SubscriptionID= s.ID                     
                      left join SubscriptionUserRelation ur on
                                 ur.SubscriptionID = s.ID
                      left join UserSecurityGroup sgu on
                                 sgu.UserID = ur.UserID
                      left join [User] u on
                                 u.UserID = ur.UserID
                      left join SubscriptionGroupRelation gr on
                                 gr.GroupID = s.ID
                      left join [Group] g on
                                 g.ID = gr.GroupID

order by
           s.ID
           ,sgu.FullName
           ,g.Name
GO
